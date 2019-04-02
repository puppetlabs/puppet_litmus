# frozen_string_literal: true

require 'rspec/core/rake_task'
require 'puppet_litmus'
require 'bolt_spec/run'
require 'open3'
require 'pdk'
require 'json'
require 'parallel'

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

def run_local_command(command)
  stdout, stderr, status = Open3.capture3(command)
  error_message = "Attempted to run\ncommand:'#{command}'\nstdout:#{stdout}\nstderr:#{stderr}"
  raise error_message unless status.to_i.zero?

  stdout
end

namespace :litmus do
  desc 'print all supported OSes from metadata'
  task :metadata do
    metadata = JSON.parse(File.read('metadata.json'))
    get_metadata_operating_systems(metadata) do |os_and_version|
      puts os_and_version
    end
  end

  desc "provision all supported OSes on with abs eg 'bundle exec rake 'litmus:provision_from_metadata'"
  task :provision_from_metadata, [:provisioner] do |_task, args|
    metadata = JSON.parse(File.read('metadata.json'))
    get_metadata_operating_systems(metadata) do |os_and_version|
      puts os_and_version
      include PuppetLitmus
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

  desc "provision list of machines from provision.yaml file. 'bundle exec rake 'litmus:provision_list[default]'"
  task :provision_list, [:key] do |_task, args|
    provision_hash = YAML.load_file('./provision.yaml')
    provisioner = provision_hash[args[:key]]['provisioner']
    provision_hash[args[:key]]['images'].each do |image|
      Rake::Task['litmus:provision'].invoke(provisioner, image)
      Rake::Task['litmus:provision'].reenable
    end
  end

  desc "provision container/VM - abs/docker/vmpooler eg 'bundle exec rake 'litmus:provision[vmpooler, ubuntu-1604-x86_64]'"
  task :provision, [:provisioner, :platform] do |_task, args|
    include PuppetLitmus
    Rake::Task['spec_prep'].invoke
    config_data = { 'modulepath' => File.join(Dir.pwd, 'spec', 'fixtures', 'modules') }
    raise "the provision module was not found in #{config_data['modulepath']}, please amend the .fixtures.yml file" unless File.directory?(File.join(config_data['modulepath'], 'provision'))

    if %w[abs vmpooler].include?(args[:provisioner])
      params = { 'action' => 'provision', 'platform' => args[:platform], 'inventory' => Dir.pwd }
      results = run_task("provision::#{args[:provisioner]}", 'localhost', params, config: config_data, inventory: nil)
      results.each do |result|
        if result['status'] != 'success'
          puts "Failed #{result['node']}\n#{result}"
        else
          puts "#{result['result']['node_name']}, #{args[:platform]}"
        end
      end
    elsif args[:provisioner] == 'docker'
      params = { 'action' => 'provision', 'platform' => args[:platform], 'inventory' => Dir.pwd }
      results = run_task('provision::docker', 'localhost', params, config: config_data, inventory: nil)
      results.each do |result|
        if result['status'] != 'success'
          puts "Failed #{result['node']}\n#{result}"
        else
          puts "#{result['result']['node_name']}, #{args[:platform]}"
        end
      end
    else
      raise "Unknown provisioner '#{args[:provisioner]}', try abs/docker/vmpooler"
    end
  end

  desc 'install puppet agent, [:collection, :target_node_name]'
  task :install_agent, [:collection, :target_node_name] do |_task, args|
    puts 'install_agent'
    include BoltSpec::Run
    inventory_hash = inventory_hash_from_inventory_file
    targets = find_targets(inventory_hash, args[:target_node_name])
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
        puts "Failed on #{result['node']}\n#{result}"
      end
    end

    # fix the path on ssh_nodes
    results = run_command('echo PATH="$PATH:/opt/puppetlabs/puppet/bin" > /etc/environment', 'ssh_nodes', config: nil, inventory: inventory_hash) unless inventory_hash['groups'].select { |group| group['name'] == 'ssh_nodes' }.size.zero? # rubocop:disable Metrics/LineLength
    results.each do |result|
      if result['status'] != 'success'
        puts "Failed on #{result['node']}\n#{result}"
      end
    end
  end

  desc 'install_module - build and install module'
  task :install_module, [:target_node_name] do |_task, args|
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

    inventory_hash = inventory_hash_from_inventory_file
    target_nodes = find_targets(inventory_hash, args[:target_node_name])
    # module_tar = Dir.glob('pkg/*.tar.gz').max_by { |f| File.mtime(f) }
    raise "Unable to find package in 'pkg/*.tar.gz'" if module_tar.nil?

    target_string = if args[:target_node_name].nil?
                      'all'
                    else
                      args[:target_node_name]
                    end
    run_local_command("bundle exec bolt file upload #{module_tar} /tmp/#{File.basename(module_tar)} --nodes #{target_string} --inventoryfile inventory.yaml")
    install_module_command = "puppet module install /tmp/#{File.basename(module_tar)}"
    result = run_command(install_module_command, target_nodes, config: nil, inventory: inventory_hash)
    # rubocop:disable Style/GuardClause
    if result.is_a?(Array)
      result.each do |node|
        puts "#{node['node']} failed #{node['result']}" if node['status'] != 'success'
      end
    else
      raise "Failed trying to run '#{install_module_command}' against inventory."
    end
    # rubocop:enable Style/GuardClause
    puts 'Installed'
  end

  desc 'tear-down - decommission machines'
  task :tear_down, [:target] do |_task, args|
    Rake::Task['spec_prep'].invoke
    config_data = { 'modulepath' => File.join(Dir.pwd, 'spec', 'fixtures', 'modules') }
    raise "the provision module was not found in #{config_data['modulepath']}, please amend the .fixtures.yml file" unless File.directory?(File.join(config_data['modulepath'], 'provision'))

    inventory_hash = inventory_hash_from_inventory_file
    targets = find_targets(inventory_hash, args[:target])
    bad_results = []
    targets.each do |node_name|
      # how do we know what provisioner to use
      node_facts = facts_from_node(inventory_hash, node_name)
      next unless %w[abs docker vmpooler].include?(node_facts['provisioner'])

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
    include PuppetLitmus
    if File.file?('inventory.yaml')
      inventory_hash = inventory_hash_from_inventory_file
      hosts = find_targets(inventory_hash, nil)

      desc 'Run tests in parallel against all machines in the inventory file'
      task :parallel do
        args = []
        hosts.each do |host|
          args << "TARGET_HOST=#{host} bundle exec rspec ./spec/acceptance --format progress --format html --out html/#{host}.html"
        end
        results = Parallel.map(args, progress: "Running against #{hosts.size} machines") do |test|
          _stdout, _stderr, _status = Open3.capture3(test)
        end
        # if any result is nonzero, there were test failures
        failures = false
        results.each do |result|
          failures = true unless result.last.exitstatus.zero?
          puts result
        end
        exit 1 if failures
      end

      hosts.each do |host|
        desc "Run serverspec against #{host}"
        RSpec::Core::RakeTask.new(host.to_sym) do |t|
          t.pattern = 'spec/acceptance/**{,/*/**}/*_spec.rb'
          ENV['TARGET_HOST'] = host
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
