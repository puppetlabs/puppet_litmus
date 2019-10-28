# frozen_string_literal: true

require 'rspec/core/rake_task'
require 'puppet_litmus'
require 'bolt_spec/run'
require 'pdk'
require 'json'
require 'parallel'
require 'tty-spinner'

namespace :litmus do
  include PuppetLitmus::RakeHelper
  # Prints all supported OSes from metadata.json file.
  desc 'print all supported OSes from metadata'
  task :metadata do
    metadata = JSON.parse(File.read('metadata.json'))
    get_metadata_operating_systems(metadata) do |os_and_version|
      puts os_and_version
    end
  end

  # Provisions a list of OSes from provision.yaml file e.g. 'bundle exec rake litmus:provision_list[default]'.
  # @See https://github.com/puppetlabs/puppet_litmus/wiki/Overview-of-Litmus#provisioning-via-yaml
  #
  # @param :key [String] key that maps to a value for a provisioner and an image to be used for each OS provisioned.
  desc "provision list of machines from provision.yaml file. 'bundle exec rake 'litmus:provision_list[default]'"
  task :provision_list, [:key] do |_task, args|
    raise 'Cannot find provision.yaml file' unless File.file?('./provision.yaml')

    provision_hash = YAML.load_file('./provision.yaml')
    raise "No key #{args[:key]} in ./provision.yaml, see https://github.com/puppetlabs/puppet_litmus/wiki/Overview-of-Litmus#provisioning-via-yaml for examples" if provision_hash[args[:key]].nil?

    results = provision_list(provision_hash, args[:key])
    failed_image_message = ''
    results.each do |result|
      if result.first['status'] != 'success'
        failed_image_message += "=====\n#{result.first['node']}\n#{result.first['result']['_output']}\n"
      else
        STDOUT.puts result.first['result']['_output']
      end
    end
    raise "Failed to provision with '#{provisioner}'\n #{failed_image_message}" unless failed_image_message.empty?
  end

  # Provision a container or VM with a given platform 'bundle exec rake 'litmus:provision[vmpooler, ubuntu-1604-x86_64]'.
  #
  # @param :provisioner [String] provisioner to use in provisioning given platform.
  # @param :platform [String] OS platform for container or VM to use.
  desc "provision container/VM - abs/docker/vagrant/vmpooler eg 'bundle exec rake 'litmus:provision[vmpooler, ubuntu-1604-x86_64]'"
  task :provision, [:provisioner, :platform, :inventory_vars] do |_task, args|
    Rake::Task['spec_prep'].invoke
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
    results = provision(args[:provisioner], args[:platform], args[:inventory_vars])
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

    results = install_agent(args[:collection], targets, inventory_hash)
    results.each do |result|
      if result['status'] != 'success'
        command_to_run = "bolt task run puppet_agent::install --targets #{result['node']} --inventoryfile inventory.yaml --modulepath #{config_data['modulepath']}"
        raise "Failed on #{result['node']}\n#{result}\ntry running '#{command_to_run}'"
      else
        # add puppet-agent feature to successful nodes
        inventory_hash = add_feature_to_node(inventory_hash, 'puppet-agent', result['node'])
      end
    end
    # update the inventory with the puppet-agent feature set per node
    write_to_inventory_file(inventory_hash, 'inventory.yaml')

    # fix the path on ssh_nodes
    results = configure_path(inventory_hash)

    results.each do |result|
      if result['status'] != 'success'
        puts "Failed on #{result['node']}\n#{result}"
      end
    end
  end

  # Install the puppet modules from a source directory to nodes. It does not install dependencies.
  #
  # @param :source [String] source directory to look in (ignores symlinks) defaults do './spec/fixtures/modules'.
  # @param :target_node_name [Array] nodes on which to install a puppet module for testing.
  desc 'install_module - build and install module'
  task :install_modules_from_directory, [:source, :target_node_name] do |_task, args|
    inventory_hash = inventory_hash_from_inventory_file
    target_nodes = find_targets(inventory_hash, args[:target_node_name])
    if target_nodes.empty?
      puts 'No targets found'
      exit 0
    end
    source_folder = if args[:source].nil?
                      './spec/fixtures/modules'
                    else
                      File.expand_path(args[:source])
                    end
    raise "Source folder doesnt exist #{source_folder}" unless File.directory?(source_folder)

    module_tars = build_modules_in_folder(source_folder)
    puts 'Building'
    module_tars.each do |module_tar|
      print "#{File.basename(module_tar)} "
    end
    include BoltSpec::Run
    puts "\nSending"
    module_tars.each do |module_tar|
      upload_file(module_tar.path, "/tmp/#{File.basename(module_tar)}", target_nodes, options: {}, config: nil, inventory: inventory_hash)
      print "#{File.basename(module_tar)} "
    end
    puts "\nInstalling"
    module_tars.each do |module_tar|
      # install_module
      install_module_command = "puppet module install --force /tmp/#{File.basename(module_tar)}"
      run_command(install_module_command, target_nodes, config: nil, inventory: inventory_hash)
      print "#{File.basename(module_tar)} "
    end
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

    opts = {}
    opts[:force] = true
    module_tar = build_module(opts)
    puts 'Built'

    # module_tar = Dir.glob('pkg/*.tar.gz').max_by { |f| File.mtime(f) }
    raise "Unable to find package in 'pkg/*.tar.gz'" if module_tar.nil?

    result = install_module(inventory_hash, args[:target_node_name], module_tar)

    raise "Failed trying to run 'puppet module install /tmp/#{File.basename(module_tar)}' against inventory." unless result.is_a?(Array)

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
    Rake::Task['spec_prep'].invoke
    bad_results = []
    results = tear_down_nodes(targets, inventory_hash)
    results.each do |node, result|
      puts result.first['status']
      if result.first['status'] != 'success'
        bad_results << "#{node}, #{result.first['result']['_error']['msg']}"
      else
        print "#{node}, "
      end
    end
    puts ''
    # output the things that went wrong, after the successes
    puts 'something went wrong:' unless bad_results.size.zero?
    bad_results.each do |result|
      puts result
    end
  end

  # Uninstall the puppet module under test on a collection of nodes
  #
  # @param :target_node_name [Array] nodes on which to install a puppet module for testing.
  # @param :module_name [String] module name to be uninstalled
  desc 'uninstall_module - uninstall module'
  task :uninstall_module, [:target_node_name, :module_name] do |_task, args|
    inventory_hash = inventory_hash_from_inventory_file
    target_nodes = find_targets(inventory_hash, args[:target_node_name])
    if target_nodes.empty?
      puts 'No targets found'
      exit 0
    end

    result = uninstall_module(inventory_hash, args[:target_node_name], args[:module_name])

    raise "Failed trying to run 'puppet module uninstall #{module_name}' against inventory." unless result.is_a?(Array)

    result.each do |node|
      puts "#{node['node']} failed #{node['result']}" if node['status'] != 'success'
    end

    puts 'Uninstalled'
  end

  # Reinstall the puppet module under test on a collection of nodes
  #
  # @param :target_node_name [Array] nodes on which to install a puppet module for testing.
  desc 'reinstall_module - reinstall module'
  task :reinstall_module, [:target_node_name] do |_task, args|
    Rake::Task['litmus:uninstall_module'].invoke(args[:target_node_name])
    Rake::Task['litmus:install_module'].invoke(args[:target_node_name])
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
          test = 'bundle exec rspec ./spec/acceptance --format progress'
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
        next if target == 'litmus_localhost'

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
