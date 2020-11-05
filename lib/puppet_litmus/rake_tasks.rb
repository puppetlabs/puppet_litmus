# frozen_string_literal: true

require 'rake'

namespace :litmus do
  require 'puppet_litmus/inventory_manipulation'
  require 'puppet_litmus/rake_helper'
  include PuppetLitmus::InventoryManipulation
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
  # @See https://puppetlabs.github.io/litmus/Litmus-core-commands.html#provisioning-via-yaml
  #
  # @param :key [String] key that maps to a value for a provisioner and an image to be used for each OS provisioned.
  desc 'provision list of machines from provision.yaml file'
  task :provision_list, [:key] do |_task, args|
    raise 'Cannot find provision.yaml file' unless File.file?('./provision.yaml')

    provision_hash = YAML.load_file('./provision.yaml')
    raise "No key #{args[:key]} in ./provision.yaml, see https://puppetlabs.github.io/litmus/Litmus-core-commands.html#provisioning-via-yaml for examples" if provision_hash[args[:key]].nil?

    Rake::Task['spec_prep'].invoke

    provisioner = provision_hash[args[:key]]['provisioner']
    inventory_vars = provision_hash[args[:key]]['vars']
    # Splat the params into environment variables to pass to the provision task but only in this runspace
    provision_hash[args[:key]]['params']&.each { |k, value| ENV[k.upcase] = value.to_s }
    results = []
    failed_image_message = ''
    provision_hash[args[:key]]['images'].each do |image|
      if (ENV['CI'] == 'true') || !ENV['DISTELLI_BUILDNUM'].nil?
        progress = Thread.new do
          loop do
            printf '.'
            sleep(10)
          end
        end
      else
        require 'tty-spinner'
        spinner = TTY::Spinner.new("Provisioning #{image} using #{provisioner} provisioner.[:spinner]")
        spinner.auto_spin
      end
      result = provision(provisioner, image, inventory_vars)

      if (ENV['CI'] == 'true') || !ENV['DISTELLI_BUILDNUM'].nil?
        Thread.kill(progress)
      else
        spinner.success
      end

      if result.first['status'] != 'success'
        failed_image_message += "=====\n#{result.first['target']}\n#{result.first['value']['_output']}\n#{result.inspect}"
      else
        STDOUT.puts "#{result.first['value']['node_name']}, #{image}"
      end
      results << result
    end

    raise "Failed to provision with '#{provisioner}'\n #{failed_image_message}" unless failed_image_message.empty?
  end

  # Provision a container or VM with a given platform 'bundle exec rake 'litmus:provision[vmpooler, ubuntu-1604-x86_64]'.
  #
  # @param :provisioner [String] provisioner to use in provisioning given platform.
  # @param :platform [String] OS platform for container or VM to use.
  desc 'provision a test system using the given provisioner and platform name. See the puppetlabs-provision module tasks for more documentation'
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
      require 'tty-spinner'
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
    puts "#{results.first['value']['node_name']}, #{args[:platform]}"
  end

  # Install puppet agent on a collection of nodes
  #
  # @param :collection [String] parameters to pass to the puppet agent install command.
  # @param :target_node_name [Array] nodes on which to install puppet agent.
  desc 'install a puppet agent to all or a specified set of targets'
  task :install_agent, [:collection, :target_node_name] do |_task, args|
    inventory_hash = inventory_hash_from_inventory_file
    targets = find_targets(inventory_hash, args[:target_node_name])
    if targets.empty?
      puts 'No targets found'
      exit 0
    end
    puts 'install_agent'
    require 'bolt_spec/run'
    include BoltSpec::Run
    Rake::Task['spec_prep'].invoke

    results = install_agent(args[:collection], targets, inventory_hash)
    results.each do |result|
      if result['status'] != 'success'
        command_to_run = "bolt task run puppet_agent::install --targets #{result['target']} --inventoryfile inventory.yaml --modulepath #{DEFAULT_CONFIG_DATA['modulepath']}"
        raise "Failed on #{result['target']}\n#{result}\ntry running '#{command_to_run}'"
      else
        # validate successful install
        retries = 0
        begin
          responses = run_command('puppet --version', targets, options: {}, config: DEFAULT_CONFIG_DATA, inventory: inventory_hash.clone)
          responses.each do |response|
            raise "Error checking puppet version on #{response.to_json}" if response['status'] != 'success'
          end
        rescue StandardError => e
          puts "ERROR:#{e}"
          retries += 1
          sleep 3
          retry if retries <= 3
          raise 'Failed to detect installed puppet version after 3 retries'
        end

        # add puppet-agent feature to successful nodes
        inventory_hash = add_feature_to_node(inventory_hash, 'puppet-agent', result['target'])
      end
    end
    # update the inventory with the puppet-agent feature set per node
    write_to_inventory_file(inventory_hash, 'inventory.yaml')

    # fix the path on ssh_nodes
    results = configure_path(inventory_hash)

    results.each do |result|
      if result['status'] != 'success'
        puts "Failed on #{result['target']}\n#{result}"
      end
    end
  end

  # Add a given feature to a selection of nodes
  #
  # @param :target_node_name [Array] nodes on which to add the feature.
  # @param :added_feature [String] the feature which you wish to add.
  desc 'add a feature tag to a node'
  task :add_feature, [:added_feature, :target_node_name] do |_task, args|
    inventory_hash = inventory_hash_from_inventory_file
    targets = find_targets(inventory_hash, args[:target_node_name])
    if targets.empty?
      puts 'No targets found'
      exit 0
    end
    if args[:added_feature].nil? || args[:added_feature] == ''
      puts 'No feature given'
      exit 0
    end
    puts 'add_feature'

    targets.each do |target|
      inventory_hash = add_feature_to_node(inventory_hash, args[:added_feature], target)
    end

    write_to_inventory_file(inventory_hash, 'inventory.yaml')

    puts 'Feature added'
  end

  # Install the puppet module under test on a collection of nodes
  #
  # @param :target_node_name [Array] nodes on which to install a puppet module for testing.
  desc 'build the module under test and install it onto targets'
  task :install_module, [:target_node_name, :module_repository] do |_task, args|
    args.with_defaults(target_node_name: nil, module_repository: nil)
    inventory_hash = inventory_hash_from_inventory_file
    target_nodes = find_targets(inventory_hash, args[:target_node_name])
    if target_nodes.empty?
      puts 'No targets found'
      exit 0
    end

    module_tar = build_module
    puts "Built '#{module_tar}'"

    # module_tar = Dir.glob('pkg/*.tar.gz').max_by { |f| File.mtime(f) }
    raise "Unable to find package in 'pkg/*.tar.gz'" if module_tar.nil?

    install_module(inventory_hash, args[:target_node_name], module_tar, args[:module_repository])

    puts "Installed '#{module_tar}' on #{args[:target_node_name]}"
  end

  # Install the puppet modules from a source directory to nodes. It does not install dependencies.
  #
  # @param :source [String] source directory to look in (ignores symlinks) defaults do './spec/fixtures/modules'.
  # @param :target_node_name [Array] nodes on which to install a puppet module for testing.
  desc 'build and install all modules from a directory'
  task :install_modules_from_directory, [:source, :target_node_name, :module_repository, :ignore_dependencies] do |_task, args|
    args.with_defaults(source: nil, target_node_name: nil, module_repository: nil, ignore_dependencies: false)
    inventory_hash = inventory_hash_from_inventory_file
    target_nodes = find_targets(inventory_hash, args[:target_node_name])
    if target_nodes.empty?
      puts 'No targets found'
      exit 0
    end
    source_dir = if args[:source].nil?
                   './spec/fixtures/modules'
                 else
                   File.expand_path(args[:source])
                 end
    raise "Source directory doesn't exist #{source_dir}" unless File.directory?(source_dir)

    puts "Building all modules in #{source_dir.inspect}"
    module_tars = build_modules_in_dir(source_dir)
    require 'bolt_spec/run'
    include BoltSpec::Run
    module_tars.each do |module_tar|
      puts "Installing '#{module_tar}'"
      target_nodes.each do |target_node_name|
        install_module(inventory_hash, target_node_name, module_tar, args[:module_repository], args[:ignore_dependencies])
        puts "Installed '#{module_tar}' on #{target_node_name}"
      end
    end
  end

  # Uninstall the puppet module under test on a collection of nodes
  #
  # @param :target_node_name [Array] nodes on which to install a puppet module for testing.
  # @param :module_name [String] module name to be uninstalled
  desc 'uninstall a specific module'
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
      puts "#{node['target']} failed #{node['value']}" if node['status'] != 'success'
    end

    puts 'Uninstalled'
  end

  # Reinstall the puppet module under test on a collection of nodes
  #
  # @param :target_node_name [Array] nodes on which to install a puppet module for testing.
  desc 'reinstall the module under test'
  task :reinstall_module, [:target_node_name, :module_repository] do |_task, args|
    args.with_defaults(target_node_name: nil, module_repository: nil)
    Rake::Task['litmus:uninstall_module'].invoke(args[:target_node_name])
    Rake::Task['litmus:install_module'].invoke(args[:target_node_name], args[:module_repository])
  end

  # Check that the nodes in the inventory are still contactable
  #
  # @param :target_node_name [Array] nodes on which to check connnectivity
  desc 'check the connectivity to all provisioned targets'
  task :check_connectivity, [:target_node_name] do |_task, args|
    inventory_hash = inventory_hash_from_inventory_file
    target_nodes = find_targets(inventory_hash, args[:target_node_name])
    if target_nodes.empty?
      puts 'No targets found'
      exit 0
    end
    check_connectivity?(inventory_hash, args[:target_node_name])
  end

  # Provision a list of machines, install a puppet agent, and install the puppet module under test on a collection of nodes
  #
  # @param :key [String] key that maps to a value for a provisioner and an image to be used for each OS provisioned.
  # @param :collection [String] parameters to pass to the puppet agent install command.
  desc 'provision a list of machines, install an agent, and the module.'
  task :provision_install, [:key, :collection, :module_repository] do |_task, args|
    args.with_defaults(module_repository: nil)
    Rake::Task['spec_prep'].invoke
    Rake::Task['litmus:provision_list'].invoke(args[:key])
    Rake::Task['litmus:install_agent'].invoke(args[:collection])
    Rake::Task['litmus:install_module'].invoke(nil, args[:module_repository])
  end

  # Decommissions test machines.
  #
  # @param :target [Array] nodes to remove from test environemnt and decommission.
  desc 'destroy provisioned targets'
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
      if result.first['status'] != 'success'
        bad_results << "#{node}, #{result.first['value']['_error']['msg']}"
      else
        puts "#{node}: #{result.first['status']}"
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
    require 'rspec/core/rake_task'
    if File.file?('inventory.yaml')
      inventory_hash = inventory_hash_from_inventory_file
      targets = find_targets(inventory_hash, nil)

      # Run acceptance tests against all machines in the inventory file in parallel.
      desc 'Run tests in parallel against all machines in the inventory file'
      task :parallel, [:tag] do |_task, args|
        args.with_defaults(tag: nil)
        if targets.empty?
          puts 'No targets found'
          exit 0
        end
        tag_value = if args[:tag].nil?
                      nil
                    else
                      "--tag #{args[:tag]}"
                    end
        payloads = []
        # Generate list of targets to provision
        targets.each do |target|
          test = "bundle exec rspec ./spec/acceptance #{tag_value} --format progress --require rspec_honeycomb_formatter --format RSpecHoneycombFormatter"
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

          require 'parallel'
          results = Parallel.map(payloads) do |title, test, options|
            # avoid sending the parent process' main span in the sub-processes
            # https://www.ruby-forum.com/t/at-exit-inherited-across-fork/122473/2
            at_exit { exit! }

            env = options[:env].nil? ? {} : options[:env]
            env['HTTP_X_HONEYCOMB_TRACE'] = Honeycomb.current_span.to_trace_header
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
          require 'tty-spinner'
          spinners = TTY::Spinner::Multi.new("[:spinner] Running against #{targets.size} targets.")
          payloads.each do |title, test, options|
            env = options[:env].nil? ? {} : options[:env]
            env['HTTP_X_HONEYCOMB_TRACE'] = Honeycomb.current_span.to_trace_header
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
        Rake::Task['litmus:check_connectivity'].invoke
        exit 1 if failure_list.any?
      end

      targets.each do |target|
        desc "Run serverspec against #{target}"
        next if target == 'litmus_localhost'

        RSpec::Core::RakeTask.new(target.to_sym, :tag) do |t, args|
          t.pattern = 'spec/acceptance/**{,/*/**}/*_spec.rb'
          t.rspec_opts = "--tag #{args[:tag]}" unless args[:tag].nil?
          ENV['TARGET_HOST'] = target
        end
      end
    end

    # add localhost separately
    desc 'Run serverspec against localhost, USE WITH CAUTION, this action can be potentially dangerous.'
    host = 'localhost'
    RSpec::Core::RakeTask.new(host.to_sym, :tag) do |t, args|
      t.pattern = 'spec/acceptance/**{,/*/**}/*_spec.rb'
      t.rspec_opts = "--tag #{args[:tag]}" unless args[:tag].nil?
      Rake::Task['spec_prep'].invoke
      ENV['TARGET_HOST'] = host
    end
  end
end
