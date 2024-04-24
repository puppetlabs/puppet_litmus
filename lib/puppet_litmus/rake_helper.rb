# frozen_string_literal: true

require 'bolt_spec/run'
require 'puppet_litmus/version'

# helper methods for the litmus rake tasks
module PuppetLitmus::RakeHelper
  # DEFAULT_CONFIG_DATA should be frozen for our safety, but it needs to work around https://github.com/puppetlabs/bolt/pull/1696
  DEFAULT_CONFIG_DATA = { 'modulepath' => File.join(Dir.pwd, 'spec', 'fixtures', 'modules') } # .freeze # rubocop:disable Style/MutableConstant
  SUPPORTED_PROVISIONERS = %w[abs docker docker_exp lxd provision_service vagrant vmpooler].freeze

  # Gets a string representing the operating system and version.
  #
  # @param metadata [Hash] metadata to parse for operating system info
  # @return [String] the operating system string with version info for use in provisioning.
  def get_metadata_operating_systems(metadata)
    return unless metadata.is_a?(Hash)
    return unless metadata['operatingsystem_support'].is_a?(Array)

    metadata['operatingsystem_support'].each do |os_info|
      next unless os_info['operatingsystem'] && os_info['operatingsystemrelease']

      os_name = case os_info['operatingsystem']
                when 'Amazon', 'Archlinux', 'AIX', 'OSX'
                  next
                when 'OracleLinux'
                  'oracle'
                when 'Windows'
                  'win'
                else
                  os_info['operatingsystem'].downcase
                end

      os_info['operatingsystemrelease'].each do |release|
        version = case os_name
                  when 'ubuntu', 'osx'
                    release.sub('.', '')
                  when 'sles'
                    release.gsub(%r{ SP[14]}, '')
                  when 'win'
                    release = release.delete('.') if release.include? '8.1'
                    release.sub('Server', '').sub('10', '10-pro')
                  else
                    release
                  end

        yield "#{os_name}-#{version.downcase}-x86_64".delete(' ')
      end
    end
  end

  # Executes a command on the test runner.
  #
  # @param command [String] command to execute.
  # @return [Object] the standard out stream.
  def run_local_command(command)
    require 'open3'
    stdout, stderr, status = Open3.capture3(command)
    error_message = "Attempted to run\ncommand:'#{command}'\nstdout:#{stdout}\nstderr:#{stderr}"

    raise error_message unless status.to_i.zero?

    stdout
  end

  def provision(provisioner, platform, inventory_vars)
    include ::BoltSpec::Run
    raise "the provision module was not found in #{DEFAULT_CONFIG_DATA['modulepath']}, please amend the .fixtures.yml file" unless
      File.directory?(File.join(DEFAULT_CONFIG_DATA['modulepath'], 'provision'))

    params = { 'action' => 'provision', 'platform' => platform, 'inventory' => File.join(Dir.pwd, 'spec', 'fixtures', 'litmus_inventory.yaml') }
    params['vars'] = inventory_vars unless inventory_vars.nil?

    task_name = provisioner_task(provisioner)
    bolt_result = run_task(task_name, 'localhost', params, config: DEFAULT_CONFIG_DATA, inventory: nil)
    raise_bolt_errors(bolt_result, "provisioning of #{platform} failed.")

    bolt_result
  end

  def provision_list(provision_hash, key)
    provisioner = provision_hash[key]['provisioner']
    inventory_vars = provision_hash[key]['vars']
    # Splat the params into environment variables to pass to the provision task but only in this runspace
    provision_hash[key]['params']&.each { |k, value| ENV[k.upcase] = value.to_s }
    provision_hash[key]['images'].map do |image|
      provision(provisioner, image, inventory_vars)
    end
  end

  def tear_down_nodes(targets, inventory_hash)
    include ::BoltSpec::Run
    config_data = { 'modulepath' => File.join(Dir.pwd, 'spec', 'fixtures', 'modules') }
    raise "the provision module was not found in #{config_data['modulepath']}, please amend the .fixtures.yml file" unless File.directory?(File.join(config_data['modulepath'], 'provision'))

    results = {}
    targets.each do |node_name|
      #  next if local host or provisioner fact empty/not set (GH-421)
      next if node_name == 'litmus_localhost' || facts_from_node(inventory_hash, node_name)['provisioner'].nil?

      result = tear_down(node_name, inventory_hash)
      # Some provisioners tear_down targets that were created as a batch job.
      # These provisioners should return the list of additional targets
      # removed so that we do not attempt to process them.
      if result != [] && result[0]['value'].key?('removed')
        removed_targets = result[0]['value']['removed']
        result[0]['value'].delete('removed')
        removed_targets.each do |removed_target|
          targets.delete(removed_target)
          results[removed_target] = result
        end
      end

      results[node_name] = result unless result == []
    end
    results
  end

  def tear_down(node_name, inventory_hash)
    # how do we know what provisioner to use
    add_platform_field(inventory_hash, node_name)

    params = { 'action' => 'tear_down', 'node_name' => node_name, 'inventory' => File.join(Dir.pwd, 'spec', 'fixtures', 'litmus_inventory.yaml') }
    node_facts = facts_from_node(inventory_hash, node_name)
    bolt_result = run_task(provisioner_task(node_facts['provisioner']), 'localhost', params, config: DEFAULT_CONFIG_DATA, inventory: nil)
    raise_bolt_errors(bolt_result, "tear_down of #{node_name} failed.")
    bolt_result
  end

  def install_agent(collection, targets, inventory_hash)
    include ::BoltSpec::Run
    params = if collection.nil?
               {}
             else
               { 'collection' => collection }
             end
    raise "puppet_agent was not found in #{DEFAULT_CONFIG_DATA['modulepath']}, please amend the .fixtures.yml file" \
      unless File.directory?(File.join(DEFAULT_CONFIG_DATA['modulepath'], 'puppet_agent'))

    # using boltspec, when the runner is called it changes the inventory_hash dropping the version field. The clone works around this
    bolt_result = run_task('puppet_agent::install', targets, params, config: DEFAULT_CONFIG_DATA, inventory: inventory_hash.clone)
    targets.each do |target|
      params = {
        'path' => '/opt/puppetlabs/bin'
      }
      node_facts = facts_from_node(inventory_hash, target)
      next unless node_facts['provisioner'] == 'vagrant'

      puts "Adding puppet agent binary to the secure_path on target #{target}."
      result = run_task('provision::fix_secure_path', target, params, config: DEFAULT_CONFIG_DATA, inventory: inventory_hash.clone)
      raise_bolt_errors(result, "Failed to add the Puppet agent binary to the secure_path on target #{target}.")
    end
    raise_bolt_errors(bolt_result, 'Installation of agent failed.')
    bolt_result
  end

  def configure_path(inventory_hash)
    results = []
    # fix the path on ssh_nodes
    unless inventory_hash['groups'].none? { |group| group['name'] == 'ssh_nodes' && !group['targets'].empty? }
      results << run_command('echo PATH="$PATH:/opt/puppetlabs/puppet/bin" > /etc/environment',
                             'ssh_nodes', config: nil, inventory: inventory_hash)
    end
    unless inventory_hash['groups'].none? { |group| group['name'] == 'winrm_nodes' && !group['targets'].empty? }
      results << run_command('[Environment]::SetEnvironmentVariable("Path", $env:Path + ";C:\Program Files\Puppet Labs\Puppet\bin;C:\Program Files (x86)\Puppet Labs\Puppet\bin", "Machine")',
                             'winrm_nodes', config: nil, inventory: inventory_hash)
    end
    results
  end

  # Build the module in `module_dir` and put the resulting compressed tarball into `target_dir`.
  #
  # @param opts Hash of options to build the module
  # @param module_dir [String] The path of the module to build. If missing defaults to Dir.pwd
  # @param target_dir [String] The path the module will be built into. The default is <module_dir>/pkg
  # @return [String] The path to the built module
  def build_module(module_dir = nil, target_dir = nil)
    require 'puppet/modulebuilder'

    module_dir ||= Dir.pwd
    target_dir ||= File.join(source_dir, 'pkg')

    puts "Building '#{module_dir}' into '#{target_dir}'"
    builder = Puppet::Modulebuilder::Builder.new(module_dir, target_dir, nil)

    # Force the metadata to be read. Raises if metadata could not be found
    _metadata = builder.metadata

    builder.build
  end

  # Builds all the modules in a specified directory
  #
  # @param source_dir [String] the directory to get the modules from
  # @param target_dir [String] temporary location to store tarballs before uploading. This directory will be cleaned before use. The default is <source_dir>/pkg
  # @return [Array] an array of module tars' filenames
  def build_modules_in_dir(source_dir, target_dir = nil)
    target_dir ||= File.join(Dir.pwd, 'pkg')
    # remove old build dir if exists, before we build afresh
    FileUtils.rm_rf(target_dir) if File.directory?(target_dir)

    module_tars = Dir.entries(source_dir).map do |entry|
      next if ['.', '..'].include? entry

      module_dir = File.join(source_dir, entry)
      next unless File.directory? module_dir

      build_module(module_dir, target_dir)
    end
    module_tars.compact
  end

  # @deprecated Use `build_modules_in_dir` instead
  def build_modules_in_folder(source_folder)
    build_modules_in_dir(source_folder)
  end

  # Install a specific module tarball to the specified target.
  # This method installs dependencies using a forge repository.
  #
  # @param inventory_hash [Hash] the pre-loaded inventory
  # @param target_node_name [String] the name of the target where the module should be installed
  # @param module_tar [String] the filename of the module tarball to upload
  # @param module_repository [String] the URL for the forge to use for downloading modules. Defaults to the public Forge API.
  # @param ignore_dependencies [Boolean] flag used to ignore module dependencies defaults to false.
  # @return a bolt result
  def install_module(inventory_hash, target_node_name, module_tar, module_repository = nil, ignore_dependencies = false) # rubocop:disable Style/OptionalBooleanParameter
    # make sure the module to install is not installed
    # otherwise `puppet module install` might silently skip it
    module_name = File.basename(module_tar, '.tar.gz').split('-', 3)[0..1].join('-')
    uninstall_module(inventory_hash.clone, target_node_name, module_name, force: true)

    include ::BoltSpec::Run

    target_nodes = find_targets(inventory_hash, target_node_name)
    bolt_result = upload_file(module_tar, File.basename(module_tar), target_nodes, options: {}, config: nil, inventory: inventory_hash.clone)
    raise_bolt_errors(bolt_result, 'Failed to upload module.')

    module_repository_opts = "--module_repository '#{module_repository}'" unless module_repository.nil?
    install_module_command = "puppet module install #{module_repository_opts} #{File.basename(module_tar)}"
    install_module_command += ' --ignore-dependencies --force' if ignore_dependencies.to_s.casecmp('true').zero?

    bolt_result = run_command(install_module_command, target_nodes, config: nil, inventory: inventory_hash.clone)
    raise_bolt_errors(bolt_result, "Installation of package #{File.basename(module_tar)} failed.")
    bolt_result
  end

  def metadata_module_name
    require 'json'
    raise 'Could not find metadata.json' unless File.exist?(File.join(Dir.pwd, 'metadata.json'))

    metadata = JSON.parse(File.read(File.join(Dir.pwd, 'metadata.json')))
    raise 'Could not read module name from metadata.json' if metadata['name'].nil?

    metadata['name']
  end

  # Uninstall a module from a specified target
  # @param inventory_hash [Hash] the pre-loaded inventory
  # @param target_node_name [String] the name of the target where the module should be uninstalled
  # @param module_to_remove [String] the name of the module to remove. Defaults to the module under test.
  # @param opts [Hash] additional options to pass on to `puppet module uninstall`
  def uninstall_module(inventory_hash, target_node_name, module_to_remove = nil, **opts)
    include ::BoltSpec::Run
    module_name = module_to_remove || metadata_module_name
    target_nodes = find_targets(inventory_hash, target_node_name)
    install_module_command = "puppet module uninstall #{module_name}"
    install_module_command += ' --force' if opts[:force]
    bolt_result = run_command(install_module_command, target_nodes, config: nil, inventory: inventory_hash)
    # `puppet module uninstall --force` fails if the module is not installed. Ignore errors when force is set
    raise_bolt_errors(bolt_result, "uninstalling #{module_name} failed.") unless opts[:force]
    bolt_result
  end

  def check_connectivity?(inventory_hash, target_node_name)
    # if we're only checking connectivity for a single node
    add_platform_field(inventory_hash, target_node_name) if target_node_name

    include ::BoltSpec::Run
    target_nodes = find_targets(inventory_hash, target_node_name)
    puts "Checking connectivity for #{target_nodes.inspect}"

    results = run_command('cd .', target_nodes, config: nil, inventory: inventory_hash)
    failed = []
    results.reject { |r| r['status'] == 'success' }.each do |result|
      puts "Failure connecting to #{result['target']}:\n#{result.inspect}"
      failed.push(result['target'])
    end
    raise "Connectivity has failed on: #{failed}" unless failed.empty?

    puts 'Connectivity check PASSED.'
    true
  end

  def provisioner_task(provisioner)
    if SUPPORTED_PROVISIONERS.include?(provisioner)
      "provision::#{provisioner}"
    else
      warn "WARNING: Unsupported provisioner '#{provisioner}', try #{SUPPORTED_PROVISIONERS.join('/')}"
      provisioner.to_s
    end
  end

  # Parse out errors messages in result set returned by Bolt command.
  #
  # @param result_set [Array] result set returned by Bolt command.
  # @return [Hash] Errors grouped by target.
  def check_bolt_errors(result_set)
    errors = {}
    # iterate through each error
    result_set.each do |target_result|
      status = target_result['status']
      # jump to the next one when there is not fail
      next if status != 'failure'

      target = target_result['target']
      # get some info from error
      errors[target] = target_result['value']
    end
    errors
  end

  # Parse out errors messages in result set returned by Bolt command. If there are errors, raise them.
  #
  # @param result_set [Array] result set returned by Bolt command.
  # @param error_msg [String] error message to raise when errors are detected. The actual errors will be appended.
  def raise_bolt_errors(result_set, error_msg)
    errors = check_bolt_errors(result_set)

    unless errors.empty?
      formatted_results = errors.map { |k, v| "  #{k}: #{v.inspect}" }.join("\n")
      raise "#{error_msg}\nResults:\n#{formatted_results}}"
    end

    nil
  end

  def start_spinner(message)
    if (ENV['CI'] || '').casecmp('true').zero? || Gem.win_platform?
      puts message
      spinner = Thread.new do
        # CI systems are strange beasts, we only output a '.' every wee while to keep the terminal alive.
        loop do
          printf '.'
          sleep(10)
        end
      end
    else
      require 'tty-spinner'
      spinner = TTY::Spinner.new("[:spinner] #{message}")
      spinner.auto_spin
    end
    spinner
  end

  def stop_spinner(spinner)
    if (ENV['CI'] || '').casecmp('true').zero? || Gem.win_platform?
      Thread.kill(spinner)
    else
      spinner.success
    end
  end

  require 'retryable'

  Retryable.configure do |config|
    config.sleep = ->(n) { (1.5**n) + Random.rand(0.5) }
    # config.log_method = ->(retries, exception) do
    #   Logger.new($stdout).debug("[Attempt ##{retries}] Retrying because [#{exception.class} - #{exception.message}]: #{exception.backtrace.first(5).join(' | ')}")
    # end
  end

  class LitmusTimeoutError < StandardError; end

  def with_retries(options: { tries: Float::INFINITY }, max_wait_minutes: 15)
    stop = Time.now + (max_wait_minutes * 60)
    Retryable.retryable(options.merge(not: [LitmusTimeoutError])) do
      raise LitmusTimeoutError if Time.now > stop

      yield
    end
  end
end
