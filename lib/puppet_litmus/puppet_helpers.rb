# frozen_string_literal: true

# helper functions for running puppet commands. They execute a target system specified by ENV['TARGET_HOST']
# heavily uses functions from here https://github.com/puppetlabs/bolt/blob/master/developer-docs/bolt_spec-run.md
module PuppetLitmus::PuppetHelpers
  # Applies a manifest twice. First checking for errors. Secondly to make sure no changes occur.
  #
  # @param manifest [String] puppet manifest code to be applied.
  # @return [Boolean] The result of the 2 apply manifests.
  def idempotent_apply(manifest)
    Honeycomb.start_span(name: 'litmus.idempotent_apply') do
      manifest_file_location = create_manifest_file(manifest)
      apply_manifest(nil, expect_failures: false, manifest_file_location: manifest_file_location)
      apply_manifest(nil, catch_changes: true, manifest_file_location: manifest_file_location)
    end
  end

  # Applies a manifest. returning the result of that apply. Mimics the apply_manifest from beaker
  #
  # When you set the environment variable RSPEC_DEBUG, the output of your
  # puppet run will be displayed. If you have set the :debug flag, you will see the
  # full debug log. If you have **not** set the :debug flag, it will display the regular
  # output.
  #
  # @param manifest [String] puppet manifest code to be applied.
  # @param opts [Hash] Alters the behaviour of the command. Valid options are:
  #  :catch_changes [Boolean] (false) We're after idempotency so allow exit code 0 only.
  #  :expect_changes [Boolean] (false) We're after changes specifically so allow exit code 2 only.
  #  :catch_failures [Boolean] (false) We're after only complete success so allow exit codes 0 and 2 only.
  #  :expect_failures [Boolean] (false) We're after failures specifically so allow exit codes 1, 4, and 6 only.
  #  :manifest_file_location [Path] The place on the target system.
  #  :hiera_config [Path] The path to the hiera.yaml configuration on the runner.
  #  :prefix_command [String] prefixes the puppet apply command; eg "export LANGUAGE='ja'".
  #  :debug [Boolean] run puppet apply with the debug flag.
  #  :noop [Boolean] run puppet apply with the noop flag.
  # @yieldreturn [Block] this method will yield to a block of code passed by the caller; this can be used for additional validation, etc.
  # @return [Object] A result object from the apply.
  def apply_manifest(manifest, opts = {})
    Honeycomb.start_span(name: 'litmus.apply_manifest') do |span|
      span.add_field('litmus.manifest', manifest)
      span.add_field('litmus.opts', opts)

      target_node_name = targeting_localhost? ? 'litmus_localhost' : ENV['TARGET_HOST']
      raise 'manifest and manifest_file_location in the opts hash are mutually exclusive arguments, pick one' if !manifest.nil? && !opts[:manifest_file_location].nil?
      raise 'please pass a manifest or the manifest_file_location in the opts hash' if (manifest.nil? || manifest == '') && opts[:manifest_file_location].nil?
      raise 'please specify only one of `catch_changes`, `expect_changes`, `catch_failures` or `expect_failures`' if
        [opts[:catch_changes], opts[:expect_changes], opts[:catch_failures], opts[:expect_failures]].compact.length > 1

      if opts[:catch_changes]
        use_detailed_exit_codes = true
        acceptable_exit_codes = [0]
      elsif opts[:catch_failures]
        use_detailed_exit_codes = true
        acceptable_exit_codes = [0, 2]
      elsif opts[:expect_failures]
        use_detailed_exit_codes = true
        acceptable_exit_codes = [1, 4, 6]
      elsif opts[:expect_changes]
        use_detailed_exit_codes = true
        acceptable_exit_codes = [2]
      else
        use_detailed_exit_codes = false
        acceptable_exit_codes = [0]
      end

      manifest_file_location = opts[:manifest_file_location] || create_manifest_file(manifest)
      inventory_hash = File.exist?('inventory.yaml') ? inventory_hash_from_inventory_file : localhost_inventory_hash
      raise "Target '#{target_node_name}' not found in inventory.yaml" unless target_in_inventory?(inventory_hash, target_node_name)

      command_to_run = "#{opts[:prefix_command]} puppet apply #{manifest_file_location}"
      command_to_run += " --modulepath #{Dir.pwd}/spec/fixtures/modules" if target_node_name == 'litmus_localhost'
      command_to_run += " --hiera_config='#{opts[:hiera_config]}'" unless opts[:hiera_config].nil?
      command_to_run += ' --debug' if !opts[:debug].nil? && (opts[:debug] == true)
      command_to_run += ' --noop' if !opts[:noop].nil? && (opts[:noop] == true)
      command_to_run += ' --detailed-exitcodes' if use_detailed_exit_codes == true

      span.add_field('litmus.command_to_run', command_to_run)
      span.add_field('litmus.target_node_name', target_node_name)
      bolt_result = run_command(command_to_run, target_node_name, config: nil, inventory: inventory_hash)
      span.add_field('litmus.bolt_result', bolt_result)

      result = OpenStruct.new(exit_code: bolt_result.first['result']['exit_code'],
                              stdout: bolt_result.first['result']['stdout'],
                              stderr: bolt_result.first['result']['stderr'])
      span.add_field('litmus.result', result.to_h)

      status = result.exit_code
      if opts[:catch_changes] && !acceptable_exit_codes.include?(status)
        report_puppet_apply_change(command_to_run, bolt_result)
      elsif !acceptable_exit_codes.include?(status)
        report_puppet_apply_error(command_to_run, bolt_result, acceptable_exit_codes)
      end

      yield result if block_given?

      if ENV['RSPEC_DEBUG']
        puts "apply manifest succeded\n #{command_to_run}\n======\nwith status #{result.exit_code}"
        puts result.stderr
        puts result.stdout
      end
      result
    end
  end

  # Creates a manifest file locally in a temp location, if its a remote target copy it to there.
  #
  # @param manifest [String] puppet manifest code.
  # @return [String] The path to the location of the manifest.
  def create_manifest_file(manifest)
    Honeycomb.start_span(name: 'litmus.create_manifest_file') do |span|
      span.add_field('litmus.manifest', manifest)

      require 'tmpdir'
      target_node_name = ENV['TARGET_HOST']
      tmp_filename = File.join(Dir.tmpdir, "manifest_#{Time.now.strftime('%Y%m%d')}_#{Process.pid}_#{rand(0x100000000).to_s(36)}.pp")
      manifest_file = File.open(tmp_filename, 'w')
      manifest_file.write(manifest)
      manifest_file.close
      if target_node_name.nil? || target_node_name == 'localhost'
        # no need to transfer
        manifest_file_location = manifest_file.path
      else
        # transfer to TARGET_HOST
        inventory_hash = inventory_hash_from_inventory_file
        manifest_file_location = "/tmp/#{File.basename(manifest_file)}"
        bolt_result = upload_file(manifest_file.path, manifest_file_location, target_node_name, options: {}, config: nil, inventory: inventory_hash)
        span.add_field('litmus.bolt_result', bolt_result)
        raise bolt_result.first['result'].to_s unless bolt_result.first['status'] == 'success'
      end

      span.add_field('litmus.manifest_file_location', manifest_file_location)

      manifest_file_location
    end
  end

  # Runs a command against the target system
  #
  # @param command_to_run [String] The command to execute.
  # @param opts [Hash] Alters the behaviour of the command. Valid options are :expect_failures [Boolean] doesnt return an exit code of non-zero if the command failed.
  # @yieldreturn [Block] this method will yield to a block of code passed by the caller; this can be used for additional validation, etc.
  # @return [Object] A result object from the command.
  def run_shell(command_to_run, opts = {})
    Honeycomb.start_span(name: 'litmus.run_shell') do |span|
      span.add_field('litmus.command_to_run', command_to_run)
      span.add_field('litmus.opts', opts)

      target_node_name = targeting_localhost? ? 'litmus_localhost' : ENV['TARGET_HOST']
      inventory_hash = File.exist?('inventory.yaml') ? inventory_hash_from_inventory_file : localhost_inventory_hash
      raise "Target '#{target_node_name}' not found in inventory.yaml" unless target_in_inventory?(inventory_hash, target_node_name)

      bolt_result = run_command(command_to_run, target_node_name, config: nil, inventory: inventory_hash)
      span.add_field('litmus.bolt_result', bolt_result)

      if bolt_result.first['result']['exit_code'] != 0 && opts[:expect_failures] != true
        raise "shell failed\n`#{command_to_run}`\n======\n#{bolt_result}"
      end

      result = OpenStruct.new(exit_code: bolt_result.first['result']['exit_code'],
                              exit_status: bolt_result.first['result']['exit_code'],
                              stdout: bolt_result.first['result']['stdout'],
                              stderr: bolt_result.first['result']['stderr'])
      span.add_field('litmus.result', result.to_h)
      yield result if block_given?
      result
    end
  end

  # Copies file to the target, using its respective transport
  #
  # @param source [String] place locally, to copy from.
  # @param destination [String] place on the target, to copy to.
  # @param opts [Hash] Alters the behaviour of the command. Valid options are :expect_failures [Boolean] doesnt return an exit code of non-zero if the command failed.
  # @yieldreturn [Block] this method will yield to a block of code passed by the caller; this can be used for additional validation, etc.
  # @return [Object] A result object from the command.
  def bolt_upload_file(source, destination, opts = {}, options = {})
    Honeycomb.start_span(name: 'litmus.bolt_upload_file') do |span|
      span.add_field('litmus.source', source)
      span.add_field('litmus.destination', destination)
      span.add_field('litmus.opts', opts)
      span.add_field('litmus.options', options)

      target_node_name = targeting_localhost? ? 'litmus_localhost' : ENV['TARGET_HOST']
      inventory_hash = File.exist?('inventory.yaml') ? inventory_hash_from_inventory_file : localhost_inventory_hash
      raise "Target '#{target_node_name}' not found in inventory.yaml" unless target_in_inventory?(inventory_hash, target_node_name)

      bolt_result = upload_file(source, destination, target_node_name, options: options, config: nil, inventory: inventory_hash)
      span.add_field('litmus.bolt_result', bolt_result)

      result_obj = {
        exit_code: 0,
        stdout: bolt_result.first['result']['_output'],
        stderr: nil,
        result: bolt_result.first['result'],
      }

      if bolt_result.first['status'] != 'success'
        if opts[:expect_failures] != true
          span.add_field('litmus_uploadfilefailure', bolt_result)
          raise "upload file failed\n======\n#{bolt_result}"
        end

        result_obj[:exit_code] = 255
        result_obj[:stderr]    = bolt_result.first['result']['_error']['msg']
      end

      result = OpenStruct.new(exit_code: result_obj[:exit_code],
                              stdout: result_obj[:stdout],
                              stderr: result_obj[:stderr])
      span.add_field('litmus.result', result.to_h)
      yield result if block_given?
      result
    end
  end

  # Runs a task against the target system.
  #
  # @param task_name [String] The name of the task to run.
  # @param params [Hash] key : value pairs to be passed to the task.
  # @param opts [Hash] Alters the behaviour of the command. Valid options are
  #  :expect_failures [Boolean] doesnt return an exit code of non-zero if the command failed.
  #  :inventory_file [String] path to the inventory file to use with the task.
  # @return [Object] A result object from the task.The values available are stdout, stderr and result.
  def run_bolt_task(task_name, params = {}, opts = {})
    Honeycomb.start_span(name: 'litmus.run_task') do |span|
      span.add_field('litmus.task_name', task_name)
      span.add_field('litmus.params', params)
      span.add_field('litmus.opts', opts)

      config_data = { 'modulepath' => File.join(Dir.pwd, 'spec', 'fixtures', 'modules') }
      target_node_name = targeting_localhost? ? 'litmus_localhost' : ENV['TARGET_HOST']
      inventory_hash = if !opts[:inventory_file].nil? && File.exist?(opts[:inventory_file])
                         inventory_hash_from_inventory_file(opts[:inventory_file])
                       elsif File.exist?('inventory.yaml')
                         inventory_hash_from_inventory_file('inventory.yaml')
                       else
                         localhost_inventory_hash
                       end
      raise "Target '#{target_node_name}' not found in inventory.yaml" unless target_in_inventory?(inventory_hash, target_node_name)

      bolt_result = run_task(task_name, target_node_name, params, config: config_data, inventory: inventory_hash)
      result_obj = {
        exit_code: 0,
        stdout: nil,
        stderr: nil,
        result: bolt_result.first['result'],
      }

      if bolt_result.first['status'] == 'success'
        # stdout returns unstructured data if structured data is not available
        result_obj[:stdout] = if bolt_result.first['result']['_output'].nil?
                                bolt_result.first['result'].to_s
                              else
                                bolt_result.first['result']['_output']
                              end

      else
        if opts[:expect_failures] != true
          span.add_field('litmus_runtaskfailure', bolt_result)
          raise "task failed\n`#{task_name}`\n======\n#{bolt_result}"
        end

        result_obj[:exit_code] = if bolt_result.first['result']['_error']['details'].nil?
                                   255
                                 else
                                   bolt_result.first['result']['_error']['details'].fetch('exitcode', 255)
                                 end
        result_obj[:stderr]    = bolt_result.first['result']['_error']['msg']
      end

      result = OpenStruct.new(exit_code: result_obj[:exit_code],
                              stdout: result_obj[:stdout],
                              stderr: result_obj[:stderr],
                              result: result_obj[:result])
      yield result if block_given?
      span.add_field('litmus.result', result.to_h)
      result
    end
  end

  # Runs a script against the target system.
  #
  # @param script [String] The path to the script on the source machine
  # @param opts [Hash] Alters the behaviour of the command. Valid options are :expect_failures [Boolean] doesnt return an exit code of non-zero if the command failed.
  # @param arguments [Array] Array of arguments to pass to script on runtime
  # @yieldreturn [Block] this method will yield to a block of code passed by the caller; this can be used for additional validation, etc.
  # @return [Object] A result object from the script run.
  def bolt_run_script(script, opts = {}, arguments: [])
    Honeycomb.start_span(name: 'litmus.bolt_run_script') do |span|
      span.add_field('litmus.script', script)
      span.add_field('litmus.opts', opts)
      span.add_field('litmus.arguments', arguments)

      target_node_name = targeting_localhost? ? 'litmus_localhost' : ENV['TARGET_HOST']
      inventory_hash = File.exist?('inventory.yaml') ? inventory_hash_from_inventory_file : localhost_inventory_hash
      raise "Target '#{target_node_name}' not found in inventory.yaml" unless target_in_inventory?(inventory_hash, target_node_name)

      bolt_result = run_script(script, target_node_name, arguments, options: opts, config: nil, inventory: inventory_hash)

      if bolt_result.first['result']['exit_code'] != 0 && opts[:expect_failures] != true
        span.add_field('litmus_runscriptfailure', bolt_result)
        raise "script run failed\n`#{script}`\n======\n#{bolt_result}"
      end

      result = OpenStruct.new(exit_code: bolt_result.first['result']['exit_code'],
                              stdout: bolt_result.first['result']['stdout'],
                              stderr: bolt_result.first['result']['stderr'])
      yield result if block_given?
      span.add_field('litmus.result', result.to_h)
      result
    end
  end

  # Determines if the current execution is targeting localhost or not
  #
  # @return [Boolean] true if targeting localhost in the tests
  def targeting_localhost?
    ENV['TARGET_HOST'].nil? || ENV['TARGET_HOST'] == 'localhost'
  end

  private

  # Report an error in the puppet run
  #
  # @param command [String] The puppet command causing the error.
  # @param bolt_result  [Array] The result object from bolt
  def report_puppet_apply_error(command, bolt_result, acceptable_exit_codes)
    puppet_apply_error = <<~ERROR
      apply manifest failed
      `#{command}`
      with exit code #{bolt_result.first['result']['exit_code']} (expected: #{acceptable_exit_codes})
      ====== Start output of failed Puppet apply ======
      #{puppet_output(bolt_result)}
      ====== End output of failed Puppet apply ======
    ERROR
    raise puppet_apply_error
  end

  # Report an unexpected change in the puppet run
  #
  # @param command [String] The puppet command causing the error.
  # @param bolt_result  [Array] The result object from bolt
  def report_puppet_apply_change(command, bolt_result)
    puppet_apply_changes = <<~ERROR
      apply manifest expected no changes
      `#{command}`
      ====== Start output of Puppet apply with unexpected changes ======
      #{puppet_output(bolt_result)}
      ====== End output of Puppet apply with unexpected changes ======
    ERROR
    raise puppet_apply_changes
  end

  # Return the stdout of the puppet run
  def puppet_output(bolt_result)
    bolt_result.dig(0, 'result', 'stderr').to_s << \
      bolt_result.dig(0, 'result', 'stdout').to_s
  end

  # Checks a puppet return status and returns true if it both
  # the catalog compiled and the apply was successful. Either
  # with or without changes
  #
  # @param exit_status [Integer] The status of the puppet run.
  def puppet_successful?(exit_status)
    [0, 2].include?(exit_status)
  end

  # Checks a puppet return status and returns true if
  # puppet reported any changes
  #
  # @param exit_status [Integer] The status of the puppet run.
  def puppet_changes?(exit_status)
    [2, 6].include?(exit_status)
  end
end
