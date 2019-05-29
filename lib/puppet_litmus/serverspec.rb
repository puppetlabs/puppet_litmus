# frozen_string_literal: true

# helper functions for running puppet commands. They execute a target system specified by ENV['TARGET_HOST']
# heavily uses functions from here https://github.com/puppetlabs/bolt/blob/master/developer-docs/bolt_spec-run.md
module PuppetLitmus::Serverspec
  # Applies a manifest twice. First checking for errors. Secondly to make sure no changes occur.
  #
  # @param manifest [String] puppet manifest code to be applied.
  # @return [Boolean] The result of the 2 apply manifests.
  def idempotent_apply(manifest)
    manifest_file_location = create_manifest_file(manifest)
    apply_manifest(nil, catch_failures: true, manifest_file_location: manifest_file_location)
    apply_manifest(nil, catch_changes: true, manifest_file_location: manifest_file_location)
  end

  # rubocop:disable Layout/TrailingWhitespace

  # Applies a manifest. returning the result of that apply. Mimics the apply_manifest from beaker
  #
  # @param manifest [String] puppet manifest code to be applied.
  # @param opts [Hash] Alters the behaviour of the command. Valid options are:  
  #  :catch_changes [Boolean] exit status of 1 if there were changes.  
  #  :expect_failures [Boolean] doesnt return an exit code of non-zero if the apply failed.  
  #  :manifest_file_location [Path] The place on the target system.
  #  :prefix_command [String] prefixes the puppet apply command; eg "export LANGUAGE='ja'".
  #  :debug [Boolean] run puppet apply with the debug flag.
  # @param [Block] his method will yield to a block of code passed by the caller; this can be used for additional validation, etc.
  # @return [Object] A result object from the apply.
  def apply_manifest(manifest, opts = {})
    # rubocop:enable Layout/TrailingWhitespace
    target_node_name = ENV['TARGET_HOST']
    raise 'manifest and manifest_file_location in the opts hash are mutually exclusive arguments, pick one' if !manifest.nil? && !opts[:manifest_file_location].nil?
    raise 'please pass a manifest or the manifest_file_location in the opts hash' if (manifest.nil? || manifest == '') && opts[:manifest_file_location].nil?

    manifest_file_location = opts[:manifest_file_location] || create_manifest_file(manifest)
    inventory_hash = if target_node_name.nil? || target_node_name == 'localhost'
                       nil
                     else
                       inventory_hash_from_inventory_file
                     end
    command_to_run = "#{opts[:prefix_command]} puppet apply #{manifest_file_location}"
    command_to_run += " --modulepath #{Dir.pwd}/spec/fixtures/modules" if target_node_name.nil? || target_node_name == 'localhost'
    command_to_run += ' --detailed-exitcodes' if !opts[:catch_changes].nil? && (opts[:catch_changes] == true)
    command_to_run += ' --debug' if !opts[:debug].nil? && (opts[:debug] == true)
    result = run_command(command_to_run, target_node_name, config: nil, inventory: inventory_hash)

    raise "apply manifest failed\n`#{command_to_run}`\n======\n#{result}" if result.first['result']['exit_code'] != 0 && opts[:expect_failures] != true

    result = OpenStruct.new(exit_code: result.first['result']['exit_code'],
                            stdout: result.first['result']['stdout'],
                            stderr: result.first['result']['stderr'])
    yield result if block_given?
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
  # @param [Block] his method will yield to a block of code passed by the caller; this can be used for additional validation, etc.
  # @return [Object] A result object from the command.
  def run_shell(command_to_run, opts = {})
    inventory_hash = inventory_hash_from_inventory_file
    target_node_name = ENV['TARGET_HOST']
    result = run_command(command_to_run, target_node_name, config: nil, inventory: inventory_hash)

    raise "shell failed\n`#{command_to_run}`\n======\n#{result}" if result.first['result']['exit_code'] != 0 && opts[:expect_failures] != true

    result = OpenStruct.new(exit_code: result.first['result']['exit_code'],
                            stdout: result.first['result']['stdout'],
                            stderr: result.first['result']['stderr'])
    yield result if block_given?
    result
  end

  # Runs a task against the target system.
  #
  # @param task_name [String] The name of the task to run.
  # @param params [Hash] key : value pairs to be passed to the task.
  # @return [Object] A result object from the task.
  def run_bolt_task(task_name, params = {})
    config_data = { 'modulepath' => File.join(Dir.pwd, 'spec', 'fixtures', 'modules') }
    inventory_hash = inventory_hash_from_inventory_file
    target_node_name = ENV['TARGET_HOST'] if target_node_name.nil?

    result = run_task(task_name, target_node_name, params, config: config_data, inventory: inventory_hash)

    raise "task failed\n`#{task_name}`\n======\n#{result}" if result.first['status'] != 'success'

    exit_code = if result.first['status'] == 'success'
                  0
                else
                  255
                end
    result = OpenStruct.new(exit_code: exit_code,
                            stdout: result.first['result']['status'],
                            stderr: result.first['result']['status'])
    yield result if block_given?
    result
  end
end
