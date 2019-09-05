# frozen_string_literal: true

require 'rspec/core/rake_task'
require 'puppet_litmus'
require 'bolt_spec/run'
require 'open3'
require 'pdk'
require 'json'
require 'parallel'

# helper methods for the litmus rake tasks
module LitmusRakeHelper
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
    stdout, stderr, status = Open3.capture3(command)
    error_message = "Attempted to run\ncommand:'#{command}'\nstdout:#{stdout}\nstderr:#{stderr}"
    raise error_message unless status.to_i.zero?

    stdout
  end
end

namespace :litmus do
  include LitmusRakeHelper
  # Prints all supported OSes from metadata.json file.
  desc 'print all supported OSes from metadata'
  task :metadata do
    metadata = JSON.parse(File.read('metadata.json'))
    get_metadata_operating_systems(metadata) do |os_and_version|
      puts os_and_version
    end
  end

  # DEPRECATED - Provisions all supported OSes with provisioner eg 'bundle exec rake litmus:provision_from_metadata['vmpooler']'.
  #
  # @param :provisioner [String] provisioner to use in provisioning all OSes.
  desc "DEPRECATED: provision_from_metadata task is deprecated.
  Provision all supported OSes with provisioner eg 'bundle exec rake 'litmus:provision_from_metadata'"
  task :provision_from_metadata, [:provisioner] do |_task, args|
    metadata = JSON.parse(File.read('metadata.json'))
    get_metadata_operating_systems(metadata) do |os_and_version|
      puts os_and_version
      include BoltSpec::Run
      Rake::Task['spec_prep'].invoke
      config_data = { 'modulepath' => File.join(Dir.pwd, 'spec', 'fixtures', 'modules') }
      raise "the provision module was not found in #{config_data['modulepath']}, please amend the .fixtures.yml file" unless File.directory?(File.join(config_data['modulepath'], 'provision'))

      params = { 'action' => 'provision', 'platform' => os_and_version, 'inventory' => Dir.pwd }
      results = run_task("provision::#{args[:provisioner]}", 'localhost', params, config: config_data, inventory: nil)
      results.each do |result|
        if result['status'] != 'success'
          puts "Failed on #{result['node']}\n#{result}"
        else
          puts "Provisioned #{result['result']['node_name']}"
        end
      end
    end
  end

  # Provisions a list of OSes from provision.yaml file e.g. 'bundle exec rake litmus:provision_list[default]'.
  #
  # @param :key [String] key that maps to a value for a provisioner and an image to be used for each OS provisioned.
  desc "provision list of machines from provision.yaml file. 'bundle exec rake 'litmus:provision_list[default]'"
  task :provision_list, [:key] do |_task, args|
    provision_hash = YAML.load_file('./provision.yaml')
    provisioner = provision_hash[args[:key]]['provisioner']
    # Splat the params into environment variables to pass to the provision task but only in this runspace
    provision_hash[args[:key]]['params']&.each { |key, value| ENV[key.upcase] = value.to_s }
    failed_image_message = ''
    provision_hash[args[:key]]['images'].each do |image|
      # this is the only way to capture the stdout from the rake task, it will affect pry
      capture_rake_output = StringIO.new
      $stdout = capture_rake_output
      Rake::Task['litmus:provision'].invoke(provisioner, image)
      if $stdout.string =~ %r{.status.=>.failure}
        failed_image_message += "=====\n#{image}\n#{$stdout.string}\n"
      else
        STDOUT.puts $stdout.string
      end
      Rake::Task['litmus:provision'].reenable
    end
    raise "Failed to provision with '#{provisioner}'\n #{failed_image_message}" unless failed_image_message.empty?
  end

  # Provision a container or VM with a given platform 'bundle exec rake 'litmus:provision[vmpooler, ubuntu-1604-x86_64]'.
  #
  # @param :provisioner [String] provisioner to use in provisioning given platform.
  # @param :platform [String] OS platform for container or VM to use.
  desc "provision container/VM - abs/docker/vagrant/vmpooler eg 'bundle exec rake 'litmus:provision[vmpooler, ubuntu-1604-x86_64]'"
  task :provision, [:provisioner, :platform] do |_task, args|
    include BoltSpec::Run
    Rake::Task['spec_prep'].invoke
    config_data = { 'modulepath' => File.join(Dir.pwd, 'spec', 'fixtures', 'modules') }
    raise "the provision module was not found in #{config_data['modulepath']}, please amend the .fixtures.yml file" unless File.directory?(File.join(config_data['modulepath'], 'provision'))

    unless %w[abs docker docker_exp vagrant vmpooler].include?(args[:provisioner])
      raise "Unknown provisioner '#{args[:provisioner]}', try abs/docker/vagrant/vmpooler"
    end

    params = { 'action' => 'provision', 'platform' => args[:platform], 'inventory' => Dir.pwd }
    if (ENV['CI'] == 'true') || !ENV['DISTELLI_BUILDNUM'].nil?
      progress = Thread.new do
        loop do
          printf '.'
          sleep(10)
        end
      end
    else
      spinner = TTY::Spinner.new("Provisioning #{args[:platform]} using #{args[:provisioner]} provisioner.[:spinner]")
      spinner.auto_spin
    end
    results = run_task("provision::#{args[:provisioner]}", 'localhost', params, config: config_data, inventory: nil)
    if results.first['status'] != 'success'
      raise "Failed provisioning #{args[:platform]} using #{args[:provisioner]}\n#{results.first}"
    end

    if (ENV['CI'] == 'true') || !ENV['DISTELLI_BUILDNUM'].nil?
      Thread.kill(progress)
    else
      spinner.success
    end
    puts "#{results.first['result']['node_name']}, #{args[:platform]}"
  end

  # Install puppet agent on a collection of nodes
  #
  # @param :collection [String] parameters to pass to the puppet agent install command.
  # @param :target_node_name [Array] nodes on which to install puppet agent.
  desc 'install puppet agent, [:collection, :target_node_name]'
  task :install_agent, [:collection, :target_node_name] do |_task, args|
    inventory_hash = inventory_hash_from_inventory_file
    targets = find_targets(inventory_hash, args[:target_node_name])
    if targets.empty?
      puts 'No targets found'
      exit 0
    end
    puts 'install_agent'
    include BoltSpec::Run
    Rake::Task['spec_prep'].invoke
    config_data = { 'modulepath' => File.join(Dir.pwd, 'spec', 'fixtures', 'modules') }
    params = if args[:collection].nil?
               {}
             else
               { 'collection' => args[:collection] }
             end
    raise "puppet_agent was not found in #{config_data['modulepath']}, please amend the .fixtures.yml file" unless File.directory?(File.join(config_data['modulepath'], 'puppet_agent'))

    results = run_task('puppet_agent::install', targets, params, config: config_data, inventory: inventory_hash)
    results.each do |result|
      if result['status'] != 'success'
        command_to_run = "bolt task run puppet_agent::install --targets #{result['node']} --inventoryfile inventory.yaml --modulepath #{config_data['modulepath']}"
        raise "Failed on #{result['node']}\n#{result}\ntry running '#{command_to_run}'"
      end
    end

    # fix the path on ssh_nodes
    unless inventory_hash['groups'].select { |group| group['name'] == 'ssh_nodes' }.size.zero?
      results = run_command('echo PATH="$PATH:/opt/puppetlabs/puppet/bin" > /etc/environment',
                            'ssh_nodes', config: nil, inventory: inventory_hash)
    end
    results.each do |result|
      if result['status'] != 'success'
        puts "Failed on #{result['node']}\n#{result}"
      end
    end
  end

  # Install puppet enterprise - for internal puppet employees only - Requires an el7 provisioned machine - experimental feature [:target_node_name]'
  #
  # @param :target_node_name [Array] nodes on which to install puppet agent.
  desc 'install puppet enterprise - for internal puppet employees only - Requires an el7 provisioned machine - experimental feature [:target_node_name]'
  task :install_pe, [:target_node_name] do |_task, args|
    inventory_hash = inventory_hash_from_inventory_file
    target_nodes = find_targets(inventory_hash, args[:target_node_name])
    if target_nodes.empty?
      puts 'No targets found'
      exit 0
    end
    puts 'install_pe'
    include BoltSpec::Run
    Rake::Task['spec_prep'].invoke
    config_data = { 'modulepath' => File.join(Dir.pwd, 'spec', 'fixtures', 'modules') }

    puts 'Setting up parameters'

    PE_RELEASE = 2019.0
    pe_latest_cmd = "curl http://enterprise.delivery.puppetlabs.net/#{PE_RELEASE}/ci-ready/LATEST"
    pe_latest = run_command(pe_latest_cmd, target_nodes, config: config_data, inventory: inventory_hash)
    pe_latest_string = pe_latest[0]['result']['stdout'].delete("\n")
    PE_FILE_NAME = "puppet-enterprise-#{pe_latest_string}-el-7-x86_64"
    TAR_FILE = "#{PE_FILE_NAME}.tar"
    DOWNLOAD_URL = "http://enterprise.delivery.puppetlabs.net/#{PE_RELEASE}/ci-ready/#{TAR_FILE}"

    puts 'Initiating PE download'

    # Download PE
    download_pe_cmd = "wget -q #{DOWNLOAD_URL}"
    run_command(download_pe_cmd, target_nodes, config: config_data, inventory: inventory_hash)

    puts 'PE successfully downloaded, running installer (this may take 5 or so minutes, please be patient)'

    # Install PE
    untar_cmd = "tar xvf #{TAR_FILE}"
    run_command(untar_cmd, target_nodes, config: config_data, inventory: inventory_hash)
    puts run_command("cd #{PE_FILE_NAME} && 1 | ./puppet-enterprise-installer", target_nodes, config: nil, inventory: inventory_hash)[0]['result']['stdout']

    puts 'Autosigning Certificates'

    # Set Autosign
    autosign_cmd = "echo 'autosign = true' >> /etc/puppetlabs/puppet/puppet.conf"
    run_command(autosign_cmd, target_nodes, config: config_data, inventory: inventory_hash)

    puts 'Finishing installation with a Puppet Agent run'

    run_command('puppet agent -t', target_nodes, config: config_data, inventory: inventory_hash)

    puts 'PE Installation is now complete'
  end

  # Install the puppet module under test on a collection of nodes
  #
  # @param :target_node_name [Array] nodes on which to install a puppet module for testing.
  desc 'install_module - build and install module'
  task :install_module, [:target_node_name] do |_task, args|
    inventory_hash = inventory_hash_from_inventory_file
    target_nodes = find_targets(inventory_hash, args[:target_node_name])
    if target_nodes.empty?
      puts 'No targets found'
      exit 0
    end
    include BoltSpec::Run
    # old cli_way
    # pdk_build_command = 'bundle exec pdk build  --force'
    # stdout, stderr, _status = Open3.capture3(pdk_build_command)
    # raise "Failed to run 'pdk_build_command',#{stdout} and #{stderr}" if (stderr =~ %r{completed successfully}).nil?
    require 'pdk/module/build'
    opts = {}
    opts[:force] = true
    builder = PDK::Module::Build.new(opts)
    module_tar = builder.build
    puts 'Built'

    # module_tar = Dir.glob('pkg/*.tar.gz').max_by { |f| File.mtime(f) }
    raise "Unable to find package in 'pkg/*.tar.gz'" if module_tar.nil?

    target_string = if args[:target_node_name].nil?
                      'all'
                    else
                      args[:target_node_name]
                    end
    run_local_command("bundle exec bolt file upload \"#{module_tar}\" /tmp/#{File.basename(module_tar)} --nodes #{target_string} --inventoryfile inventory.yaml")
    install_module_command = "puppet module install /tmp/#{File.basename(module_tar)}"
    result = run_command(install_module_command, target_nodes, config: nil, inventory: inventory_hash)

    raise "Failed trying to run '#{install_module_command}' against inventory." unless result.is_a?(Array)

    result.each do |node|
      puts "#{node['node']} failed #{node['result']}" if node['status'] != 'success'
    end

    puts 'Installed'
  end

  # Provision a list of machines, install a puppet agent, and install the puppet module under test on a collection of nodes
  #
  # @param :key [String] key that maps to a value for a provisioner and an image to be used for each OS provisioned.
  # @param :collection [String] parameters to pass to the puppet agent install command.
  desc 'provision_install - provision a list of machines, install an agent, and the module.'
  task :provision_install, [:key, :collection] do |_task, args|
    Rake::Task['spec_prep'].invoke
    Rake::Task['litmus:provision_list'].invoke(args[:key])
    Rake::Task['litmus:install_agent'].invoke(args[:collection])
    Rake::Task['litmus:install_module'].invoke
  end

  # Decommissions test machines.
  #
  # @param :target [Array] nodes to remove from test environemnt and decommission.
  desc 'tear-down - decommission machines'
  task :tear_down, [:target] do |_task, args|
    inventory_hash = inventory_hash_from_inventory_file
    targets = find_targets(inventory_hash, args[:target])
    if targets.empty?
      puts 'No targets found'
      exit 0
    end
    include BoltSpec::Run
    Rake::Task['spec_prep'].invoke
    config_data = { 'modulepath' => File.join(Dir.pwd, 'spec', 'fixtures', 'modules') }
    raise "the provision module was not found in #{config_data['modulepath']}, please amend the .fixtures.yml file" unless File.directory?(File.join(config_data['modulepath'], 'provision'))

    bad_results = []
    targets.each do |node_name|
      # how do we know what provisioner to use
      node_facts = facts_from_node(inventory_hash, node_name)
      next unless %w[abs docker docker_exp vagrant vmpooler].include?(node_facts['provisioner'])

      params = { 'action' => 'tear_down', 'node_name' => node_name, 'inventory' => Dir.pwd }
      result = run_task("provision::#{node_facts['provisioner']}", 'localhost', params, config: config_data, inventory: nil)
      if result.first['status'] != 'success'
        bad_results << "#{node_name}, #{result.first['result']['_error']['msg']}"
      else
        print "#{node_name}, "
      end
    end
    puts ''
    # output the things that went wrong, after the successes
    puts 'something went wrong:' unless bad_results.size.zero?
    bad_results.each do |result|
      puts result
    end
  end

  namespace :acceptance do
    include PuppetLitmus::InventoryManipulation
    if File.file?('inventory.yaml')
      inventory_hash = inventory_hash_from_inventory_file
      targets = find_targets(inventory_hash, nil)

      # Run acceptance tests against all machines in the inventory file in parallel.
      desc 'Run tests in parallel against all machines in the inventory file'
      task :parallel do
        if targets.empty?
          puts 'No targets found'
          exit 0
        end
        payloads = []
        # Generate list of targets to provision
        targets.each do |target|
          test = 'bundle exec bundle exec rspec ./spec/acceptance --format progress'
          title = "#{target}, #{facts_from_node(inventory_hash, target)['platform']}"
          options = {
            env: {
              'TARGET_HOST' => target,
            },
          }
          payloads << [title, test, options]
        end

        results = []
        success_list = []
        failure_list = []
        # Provision targets depending on what environment we're in
        if (ENV['CI'] == 'true') || !ENV['DISTELLI_BUILDNUM'].nil?
          # CI systems are strange beasts, we only output a '.' every wee while to keep the terminal alive.
          puts "Running against #{targets.size} targets.\n"
          progress = Thread.new do
            loop do
              printf '.'
              sleep(10)
            end
          end

          results = Parallel.map(payloads) do |title, test, options|
            env = options[:env].nil? ? {} : options[:env]
            stdout, stderr, status = Open3.capture3(env, test)
            ["\n================\n#{title}\n", stdout, stderr, status]
          end
          # because we cannot modify variables inside of Parallel
          results.each do |result|
            if result.last.to_i.zero?
              success_list.push(result.first.scan(%r{.*})[2])
            else
              failure_list.push(result.first.scan(%r{.*})[2])
            end
          end
          Thread.kill(progress)
        else
          spinners = TTY::Spinner::Multi.new("[:spinner] Running against #{targets.size} targets.")
          payloads.each do |title, test, options|
            env = options[:env].nil? ? {} : options[:env]
            spinners.register("[:spinner] #{title}") do |sp|
              stdout, stderr, status = Open3.capture3(env, test)
              if status.to_i.zero?
                sp.success
                success_list.push(title)
              else
                sp.error
                failure_list.push(title)
              end
              results.push(["================\n#{title}\n", stdout, stderr, status])
            end
          end
          spinners.auto_spin
          spinners.success
        end

        # output test results
        results.each do |result|
          puts result
        end

        # output test summary
        puts "Successful on #{success_list.size} nodes: #{success_list}" if success_list.any?
        puts "Failed on #{failure_list.size} nodes: #{failure_list}" if failure_list.any?
        exit 1 if failure_list.any?
      end

      # Run acceptance tests against all machines in the inventory file in serial.
      desc 'Run tests in serial against all machines in the inventory file'
      task :serial do
        # Iterate over all of the acceptance test tasks and invoke them;
        # We can rely on them always being in the format `litmus:acceptance:host_name:port`
        # The host_name might be localhost or an IP or a DNS-resolvable node.
        prefix = 'litmus:acceptance:'
        tasks = Rake::Task.tasks.select { |task| task.name =~ %r{^#{prefix}.+:\d+$} }
        tasks.each do |task|
          puts "Running acceptance tests against #{task.name[prefix.length..-1]}"
          task.invoke
        end
      end

      targets.each do |target|
        desc "Run serverspec against #{target}"
        RSpec::Core::RakeTask.new(target.to_sym) do |t|
          t.pattern = 'spec/acceptance/**{,/*/**}/*_spec.rb'
          ENV['TARGET_HOST'] = target
        end
      end
    end

    # add localhost separately
    desc 'Run serverspec against localhost, USE WITH CAUTION, this action can be potentially dangerous.'
    host = 'localhost'
    RSpec::Core::RakeTask.new(host.to_sym) do |t|
      t.pattern = 'spec/acceptance/**{,/*/**}/*_spec.rb'
      ENV['TARGET_HOST'] = host
    end
  end
end
