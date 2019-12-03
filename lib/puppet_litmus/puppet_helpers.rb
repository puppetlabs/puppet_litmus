# frozen_string_literal: true

# helper functions for running puppet commands. They execute a target system specified by ENV['TARGET_HOST']
# heavily uses functions from here https://github.com/puppetlabs/bolt/blob/master/developer-docs/bolt_spec-run.md
module PuppetLitmus::PuppetHelpers
  # Applies a manifest twice. First checking for errors. Secondly to make sure no changes occur.
  #
  # @param manifest [String] puppet manifest code to be applied.
  # @return [Boolean] The result of the 2 apply manifests.
  def idempotent_apply(manifest)
    manifest_file_location = create_manifest_file(manifest)
    apply_manifest(nil, expect_failures: false, manifest_file_location: manifest_file_location)
    apply_manifest(nil, catch_changes: true, manifest_file_location: manifest_file_location)
  end

  # rubocop:disable Layout/TrailingWhitespace

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
    # rubocop:enable Layout/TrailingWhitespace
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

    result = run_command(command_to_run, target_node_name, config: nil, inventory: inventory_hash)
    status = result.first['result']['exit_code']
    if opts[:catch_changes] && !acceptable_exit_codes.include?(status)
      report_puppet_apply_change(command_to_run, result)
    elsif !acceptable_exit_codes.include?(status)
      report_puppet_apply_error(command_to_run, result, acceptable_exit_codes)
    end

    result = OpenStruct.new(exit_code: result.first['result']['exit_code'],
                            stdout: result.first['result']['stdout'],
                            stderr: result.first['result']['stderr'])
    yield result if block_given?
    if ENV['RSPEC_DEBUG']
      puts "apply manifest succeded\n #{command_to_run}\n======\nwith status #{result.exit_code}"
      puts result.stderr
      puts result.stdout
    end
    result
  end

  # Creates a manifest file locally in a temp location, if its a remote target copy it to there.
  #
  # @param manifest [String] puppet manifest code.
  # @return [String] The path to the location of the manifest.
  def create_manifest_file(manifest)
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
      result = upload_file(manifest_file.path, manifest_file_location, target_node_name, options: {}, config: nil, inventory: inventory_hash)
      raise result.first['result'].to_s unless result.first['status'] == 'success'
    end
    manifest_file_location
  end

  # Runs a command against the target system
  #
  # @param command_to_run [String] The command to execute.
  # @param opts [Hash] Alters the behaviour of the command. Valid options are :expect_failures [Boolean] doesnt return an exit code of non-zero if the command failed.
  # @yieldreturn [Block] this method will yield to a block of code passed by the caller; this can be used for additional validation, etc.
  # @return [Object] A result object from the command.
  def run_shell(command_to_run, opts = {})
    target_node_name = targeting_localhost? ? 'litmus_localhost' : ENV['TARGET_HOST']
    inventory_hash = File.exist?('inventory.yaml') ? inventory_hash_from_inventory_file : localhost_inventory_hash
    raise "Target '#{target_node_name}' not found in inventory.yaml" unless target_in_inventory?(inventory_hash, target_node_name)

    result = run_command(command_to_run, target_node_name, config: nil, inventory: inventory_hash)
    raise "shell failed\n`#{command_to_run}`\n======\n#{result}" if result.first['result']['exit_code'] != 0 && opts[:expect_failures] != true

    result = OpenStruct.new(exit_code: result.first['result']['exit_code'],
                            exit_status: result.first['result']['exit_code'],
                            stdout: result.first['result']['stdout'],
                            stderr: result.first['result']['stderr'])
    yield result if block_given?
    result
  end

  # Copies file to the target, using its respective transport
  #
  # @param source [String] place locally, to copy from.
  # @param destination [String] place on the target, to copy to.
  # @param opts [Hash] Alters the behaviour of the command. Valid options are :expect_failures [Boolean] doesnt return an exit code of non-zero if the command failed.
  # @yieldreturn [Block] this method will yield to a block of code passed by the caller; this can be used for additional validation, etc.
  # @return [Object] A result object from the command.
  def bolt_upload_file(source, destination, opts = {}, options = {})
    target_node_name = targeting_localhost? ? 'litmus_localhost' : ENV['TARGET_HOST']
    inventory_hash = File.exist?('inventory.yaml') ? inventory_hash_from_inventory_file : localhost_inventory_hash
    raise "Target '#{target_node_name}' not found in inventory.yaml" unless target_in_inventory?(inventory_hash, target_node_name)

    result = upload_file(source, destination, target_node_name, options: options, config: nil, inventory: inventory_hash)

    result_obj = {
      exit_code: 0,
      stdout: result.first['result']['_output'],
      stderr: nil,
      result: result.first['result'],
    }

    if result.first['status'] != 'success'
      raise "upload file failed\n======\n#{result}" if opts[:expect_failures] != true

      result_obj[:exit_code] = 255
      result_obj[:stderr]    = result.first['result']['_error']['msg']
    end

    result = OpenStruct.new(exit_code: result_obj[:exit_code],
                            stdout: result_obj[:stdout],
                            stderr: result_obj[:stderr])
    yield result if block_given?
    result
  end

  # rubocop:disable Layout/TrailingWhitespace

  # Runs a task against the target system.
  #
  # @param task_name [String] The name of the task to run.
  # @param params [Hash] key : value pairs to be passed to the task.
  # @param opts [Hash] Alters the behaviour of the command. Valid options are  
  #  :expect_failures [Boolean] doesnt return an exit code of non-zero if the command failed.  
  #  :inventory_file [String] path to the inventory file to use with the task.
  # @return [Object] A result object from the task.The values available are stdout, stderr and result.
  # rubocop:enable Layout/TrailingWhitespace
  def run_bolt_task(task_name, params = {}, opts = {})
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

    result = run_task(task_name, target_node_name, params, config: config_data, inventory: inventory_hash)
    result_obj = {
      exit_code: 0,
      stdout: nil,
      stderr: nil,
      result: result.first['result'],
    }

    if result.first['status'] == 'success'
      # stdout returns unstructured data if structured data is not available
      result_obj[:stdout] = if result.first['result']['_output'].nil?
                              result.first['result'].to_s
                            else
                              result.first['result']['_output']
                            end

    else
      raise "task failed\n`#{task_name}`\n======\n#{result}" if opts[:expect_failures] != true

      result_obj[:exit_code] = if result.first['result']['_error']['details'].nil?
                                 255
                               else
                                 result.first['result']['_error']['details'].fetch('exitcode', 255)
                               end
      result_obj[:stderr]    = result.first['result']['_error']['msg']
    end

    result = OpenStruct.new(exit_code: result_obj[:exit_code],
                            stdout: result_obj[:stdout],
                            stderr: result_obj[:stderr],
                            result: result_obj[:result])
    yield result if block_given?
    result
  end

  # Runs a script against the target system.
  #
  # @param script [String] The path to the script on the source machine
  # @param opts [Hash] Alters the behaviour of the command. Valid options are :expect_failures [Boolean] doesnt return an exit code of non-zero if the command failed.
  # @param arguments [Array] Array of arguments to pass to script on runtime
  # @yieldreturn [Block] this method will yield to a block of code passed by the caller; this can be used for additional validation, etc.
  # @return [Object] A result object from the script run.
  def bolt_run_script(script, opts = {}, arguments: [])
    target_node_name = targeting_localhost? ? 'litmus_localhost' : ENV['TARGET_HOST']
    inventory_hash = File.exist?('inventory.yaml') ? inventory_hash_from_inventory_file : localhost_inventory_hash
    raise "Target '#{target_node_name}' not found in inventory.yaml" unless target_in_inventory?(inventory_hash, target_node_name)

    result = run_script(script, target_node_name, arguments, options: opts, config: nil, inventory: inventory_hash)

    raise "script run failed\n`#{script}`\n======\n#{result}" if result.first['result']['exit_code'] != 0 && opts[:expect_failures] != true

    result = OpenStruct.new(exit_code: result.first['result']['exit_code'],
                            stdout: result.first['result']['stdout'],
                            stderr: result.first['result']['stderr'])
    yield result if block_given?
    result
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
  # @param result  [Array] The result struct containing the result
  def report_puppet_apply_error(command, result, acceptable_exit_codes)
    puppet_apply_error = <<~ERROR
      apply manifest failed
      `#{command}`
      with exit code #{result.first['result']['exit_code']} (expected: #{acceptable_exit_codes})
      ====== Start output of failed Puppet apply ======
      #{puppet_output(result)}
      ====== End output of failed Puppet apply ======
    ERROR
    raise puppet_apply_error
  end

  # Report an unexpected change in the puppet run
  #
  # @param command [String] The puppet command causing the error.
  # @param result  [Array] The result struct containing the result
  def report_puppet_apply_change(command, result)
    puppet_apply_changes = <<~ERROR
      apply manifest expected no changes
      `#{command}`
      ====== Start output of Puppet apply with unexpected changes ======
      #{puppet_output(result)}
      ====== End output of Puppet apply with unexpected changes ======
    ERROR
    raise puppet_apply_changes
  end

  # Return the stdout of the puppet run
  def puppet_output(result)
    result.dig(0, 'result', 'stderr').to_s << \
      result.dig(0, 'result', 'stdout').to_s
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
