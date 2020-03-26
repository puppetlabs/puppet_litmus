# frozen_string_literal: true

require 'bolt_spec/run'
require 'honeycomb-beeline'
Honeycomb.configure do |config|
  # override client if no configuration is provided, so that the pesky libhoney warning about lack of configuration is not shown
  unless ENV['HONEYCOMB_WRITEKEY'] && ENV['HONEYCOMB_DATASET']
    config.client = Libhoney::NullClient.new
  end
end
process_span = Honeycomb.start_span(name: 'Litmus Testing', serialized_trace: ENV['HTTP_X_HONEYCOMB_TRACE'])
ENV['HTTP_X_HONEYCOMB_TRACE'] = process_span.to_trace_header unless ENV['HTTP_X_HONEYCOMB_TRACE']
Honeycomb.add_field_to_trace('litmus.pid', Process.pid)
if ENV['CI'] == 'true' && ENV['TRAVIS'] == 'true'
  Honeycomb.add_field_to_trace('module_name', ENV['TRAVIS_REPO_SLUG'])
  Honeycomb.add_field_to_trace('ci.provider', 'travis')
  Honeycomb.add_field_to_trace('ci.build_id', ENV['TRAVIS_BUILD_ID'])
  Honeycomb.add_field_to_trace('ci.build_url', ENV['TRAVIS_BUILD_WEB_URL'])
  Honeycomb.add_field_to_trace('ci.job_url', ENV['TRAVIS_JOB_WEB_URL'])
  Honeycomb.add_field_to_trace('ci.commit_message', ENV['TRAVIS_COMMIT_MESSAGE'])
  Honeycomb.add_field_to_trace('ci.sha', ENV['TRAVIS_PULL_REQUEST_SHA'] || ENV['TRAVIS_COMMIT'])
elsif ENV['CI'] == 'True' && ENV['APPVEYOR'] == 'True'
  Honeycomb.add_field_to_trace('module_name', ENV['APPVEYOR_PROJECT_SLUG'])
  Honeycomb.add_field_to_trace('ci.provider', 'appveyor')
  Honeycomb.add_field_to_trace('ci.build_id', ENV['APPVEYOR_BUILD_ID'])
  Honeycomb.add_field_to_trace('ci.build_url', "https://ci.appveyor.com/project/#{ENV['APPVEYOR_REPO_NAME']}/builds/#{ENV['APPVEYOR_BUILD_ID']}")
  Honeycomb.add_field_to_trace('ci.job_url', "https://ci.appveyor.com/project/#{ENV['APPVEYOR_REPO_NAME']}/build/job/#{ENV['APPVEYOR_JOB_ID']}")
  Honeycomb.add_field_to_trace('ci.commit_message', ENV['APPVEYOR_REPO_COMMIT_MESSAGE'])
  Honeycomb.add_field_to_trace('ci.sha', ENV['APPVEYOR_PULL_REQUEST_HEAD_COMMIT'] || ENV['APPVEYOR_REPO_COMMIT'])
elsif ENV['GITHUB_ACTIONS'] == 'true'
  Honeycomb.add_field_to_trace('module_name', ENV['GITHUB_REPOSITORY'])
  Honeycomb.add_field_to_trace('ci.provider', 'github')
  Honeycomb.add_field_to_trace('ci.build_id', ENV['GITHUB_RUN_ID'])
  Honeycomb.add_field_to_trace('ci.build_url', "https://github.com/#{ENV['GITHUB_REPOSITORY']}/actions/runs/#{ENV['GITHUB_RUN_ID']}")
  Honeycomb.add_field_to_trace('ci.sha', ENV['GITHUB_SHA'])
end
at_exit do
  process_span.send
end

# helper methods for the litmus rake tasks
module PuppetLitmus::RakeHelper
  DEFAULT_CONFIG_DATA ||= { 'modulepath' => File.join(Dir.pwd, 'spec', 'fixtures', 'modules') }.freeze
  SUPPORTED_PROVISIONERS ||= %w[abs docker docker_exp vagrant vmpooler].freeze

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
    Honeycomb.start_span(name: 'litmus.run_local_command') do |span|
      ENV['HTTP_X_HONEYCOMB_TRACE'] = span.to_trace_header unless ENV['HTTP_X_HONEYCOMB_TRACE']
      span.add_field('litmus.command', command)

      require 'open3'
      stdout, stderr, status = Open3.capture3(command)
      error_message = "Attempted to run\ncommand:'#{command}'\nstdout:#{stdout}\nstderr:#{stderr}"

      raise error_message unless status.to_i.zero?

      stdout
    end
  end

  def provision(provisioner, platform, inventory_vars)
    include ::BoltSpec::Run
    raise "the provision module was not found in #{DEFAULT_CONFIG_DATA['modulepath']}, please amend the .fixtures.yml file" unless
      File.directory?(File.join(DEFAULT_CONFIG_DATA['modulepath'], 'provision'))

    params = { 'action' => 'provision', 'platform' => platform, 'inventory' => Dir.pwd }
    params['vars'] = inventory_vars unless inventory_vars.nil?

    Honeycomb.add_field_to_trace('litmus.provisioner', provisioner)
    Honeycomb.start_span(name: 'litmus.provision') do |span|
      ENV['HTTP_X_HONEYCOMB_TRACE'] = span.to_trace_header unless ENV['HTTP_X_HONEYCOMB_TRACE']
      span.add_field('litmus.platform', platform)
      span.add_field('litmus.inventory', params['inventory'])
      span.add_field('litmus.config', DEFAULT_CONFIG_DATA)

      bolt_result = run_task(provisioner_task(provisioner), 'localhost', params, config: DEFAULT_CONFIG_DATA, inventory: nil)

      span.add_field('litmus.node_name', bolt_result&.first&.dig('result', 'node_name'))

      bolt_result
    end
  end

  def provision_list(provision_hash, key)
    provisioner = provision_hash[key]['provisioner']
    inventory_vars = provision_hash[key]['vars']
    # Splat the params into environment variables to pass to the provision task but only in this runspace
    provision_hash[key]['params']&.each { |k, value| ENV[k.upcase] = value.to_s }
    results = []

    Honeycomb.current_span.add_field('litmus.images', provision_hash[key]['images'])
    provision_hash[key]['images'].each do |image|
      results << provision(provisioner, image, inventory_vars)
    end
    results
  end

  def tear_down_nodes(targets, inventory_hash)
    Honeycomb.start_span(name: 'litmus.tear_down_nodes') do |span|
      ENV['HTTP_X_HONEYCOMB_TRACE'] = span.to_trace_header unless ENV['HTTP_X_HONEYCOMB_TRACE']
      span.add_field('litmus.targets', targets)

      include ::BoltSpec::Run
      config_data = { 'modulepath' => File.join(Dir.pwd, 'spec', 'fixtures', 'modules') }
      raise "the provision module was not found in #{config_data['modulepath']}, please amend the .fixtures.yml file" unless File.directory?(File.join(config_data['modulepath'], 'provision'))

      results = {}
      targets.each do |node_name|
        next if node_name == 'litmus_localhost'

        result = tear_down(node_name, inventory_hash)
        results[node_name] = result unless result == []
      end
      results
    end
  end

  def tear_down(node_name, inventory_hash)
    Honeycomb.start_span(name: 'litmus.tear_down') do |span|
      ENV['HTTP_X_HONEYCOMB_TRACE'] = span.to_trace_header unless ENV['HTTP_X_HONEYCOMB_TRACE']
      # how do we know what provisioner to use

      span.add_field('litmus.node_name', node_name)
      PuppetLitmus::HoneycombUtils.add_platform_field(inventory_hash, node_name)

      params = { 'action' => 'tear_down', 'node_name' => node_name, 'inventory' => Dir.pwd }
      node_facts = facts_from_node(inventory_hash, node_name)
      run_task(provisioner_task(node_facts['provisioner']), 'localhost', params, config: DEFAULT_CONFIG_DATA, inventory: nil)
    end
  end

  def install_agent(collection, targets, inventory_hash)
    Honeycomb.start_span(name: 'litmus.install_agent') do |span|
      ENV['HTTP_X_HONEYCOMB_TRACE'] = span.to_trace_header unless ENV['HTTP_X_HONEYCOMB_TRACE']
      span.add_field('litmus.collection', collection)
      span.add_field('litmus.targets', targets)

      include ::BoltSpec::Run
      params = if collection.nil?
                 {}
               else
                 Honeycomb.current_span.add_field('litmus.collection', collection)
                 { 'collection' => collection }
               end
      raise "puppet_agent was not found in #{DEFAULT_CONFIG_DATA['modulepath']}, please amend the .fixtures.yml file" \
       unless File.directory?(File.join(DEFAULT_CONFIG_DATA['modulepath'], 'puppet_agent'))

      # using boltspec, when the runner is called it changes the inventory_hash dropping the version field. The clone works around this
      run_task('puppet_agent::install', targets, params, config: DEFAULT_CONFIG_DATA, inventory: inventory_hash.clone)
    end
  end

  def configure_path(inventory_hash)
    results = []
    # fix the path on ssh_nodes
    unless inventory_hash['groups'].select { |group| group['name'] == 'ssh_nodes' }.size.zero?
      results = run_command('echo PATH="$PATH:/opt/puppetlabs/puppet/bin" > /etc/environment',
                            'ssh_nodes', config: nil, inventory: inventory_hash)
    end
    results
  end

  # @param opts Hash of options to build the module
  # @param module_dir [String] The path of the module to build. If missing defaults to Dir.pwd
  # @param target_dir [String] The path the module will be built into. The default is <source_dir>/pkg
  # @return [String] The path to the built module
  def build_module(module_dir = nil, target_dir = nil)
    require 'puppet/modulebuilder'

    source_dir = module_dir || Dir.pwd
    dest_dir = target_dir || File.join(source_dir, 'pkg')

    builder = Puppet::Modulebuilder::Builder.new(source_dir, dest_dir, nil)
    # Force the metadata to be read. Raises if metadata could not be found
    _metadata = builder.metadata

    builder.build
  end

  def install_module(inventory_hash, target_node_name, module_tar, module_repository = 'https://forgeapi.puppetlabs.com')
    Honeycomb.start_span(name: 'install_module') do |span|
      ENV['HTTP_X_HONEYCOMB_TRACE'] = span.to_trace_header unless ENV['HTTP_X_HONEYCOMB_TRACE']
      span.add_field('litmus.target_node_name', target_node_name)
      span.add_field('litmus.module_tar', module_tar)

      include ::BoltSpec::Run

      target_nodes = find_targets(inventory_hash, target_node_name)
      span.add_field('litmus.target_nodes', target_nodes)
      bolt_result = upload_file(module_tar, "/tmp/#{File.basename(module_tar)}", target_nodes, options: {}, config: nil, inventory: inventory_hash)
      check_bolt_errors(bolt_result)

      install_module_command = "puppet module install --module_repository #{module_repository} /tmp/#{File.basename(module_tar)}"
      span.add_field('litmus.install_module_command', install_module_command)
      run_command(install_module_command, target_nodes, config: nil, inventory: inventory_hash)
    end
  end

  # Builds all the modules in a specified module
  #
  # @param source_folder [String] the folder to get the modules from
  # @return [Array] an array of module tar's
  def build_modules_in_folder(source_folder)
    folder_list = Dir.entries(source_folder).reject { |f| File.directory? f }
    module_tars = []

    target_dir = File.join(Dir.pwd, 'pkg')
    # remove old build folder if exists, before we build afresh
    FileUtils.rm_rf(target_dir) if File.directory?(target_dir)

    folder_list.each do |folder|
      folder_handle = Dir.open(File.join(source_folder, folder))
      next if File.symlink?(folder_handle)

      module_dir = folder_handle.path

      # build_module
      module_tar = build_module(module_dir, target_dir)
      module_tars.push(File.new(module_tar))
    end
    module_tars
  end

  def metadata_module_name
    require 'json'
    raise 'Could not find metadata.json' unless File.exist?(File.join(Dir.pwd, 'metadata.json'))

    metadata = JSON.parse(File.read(File.join(Dir.pwd, 'metadata.json')))
    raise 'Could not read module name from metadata.json' if metadata['name'].nil?

    metadata['name']
  end

  def uninstall_module(inventory_hash, target_node_name, module_to_remove = nil)
    include ::BoltSpec::Run
    module_name = module_to_remove || metadata_module_name
    target_nodes = find_targets(inventory_hash, target_node_name)
    install_module_command = "puppet module uninstall #{module_name}"
    run_command(install_module_command, target_nodes, config: nil, inventory: inventory_hash)
  end

  def check_connectivity?(inventory_hash, target_node_name)
    Honeycomb.start_span(name: 'litmus.check_connectivity') do |span|
      ENV['HTTP_X_HONEYCOMB_TRACE'] = span.to_trace_header unless ENV['HTTP_X_HONEYCOMB_TRACE']
      # if we're only checking connectivity for a single node
      if target_node_name
        span.add_field('litmus.node_name', target_node_name)
        PuppetLitmus::HoneycombUtils.add_platform_field(inventory_hash, target_node_name)
      end

      include ::BoltSpec::Run
      target_nodes = find_targets(inventory_hash, target_node_name)
      results = run_command('cd .', target_nodes, config: nil, inventory: inventory_hash)
      span.add_field('litmus.bolt_result', results)
      failed = []
      results.each do |result|
        failed.push(result['target']) if result['status'] == 'failure'
      end
      span.add_field('litmus.connectivity_failed', failed)
      raise "Connectivity has failed on: #{failed}" unless failed.length.zero?

      true
    end
  end

  def provisioner_task(provisioner)
    if SUPPORTED_PROVISIONERS.include?(provisioner)
      "provision::#{provisioner}"
    else
      warn "WARNING: Unsuported provisioner '#{provisioner}', try #{SUPPORTED_PROVISIONERS.join('/')}"
      provisioner.to_s
    end
  end

  # Parse out errors messages in result set returned by Bolt command.
  #
  # @param result_set [Array] result set returned by Bolt command.
  # @return [Hash] Error messages grouped by target.
  def check_bolt_errors(result_set)
    errors = {}
    # iterate through each error
    result_set.each do |target_result|
      status = target_result['status']
      # jump to the next one when there is not fail
      next if status != 'failure'

      target = target_result['target']
      # get some info from error
      error_msg = target_result['result']['_error']['msg']
      errors[target] = error_msg
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
      raise "#{error_msg}\nErrors: #{errors}"
    end

    nil
  end
end
