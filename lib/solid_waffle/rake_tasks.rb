# frozen_string_literal: true

require 'rspec/core/rake_task'
require 'solid_waffle'
require 'bolt_spec/run'
require 'open3'
require 'pdk'

def run_local_command(command)
  stdout, stderr, status = Open3.capture3(command)
  error_message = "Attempted to run\ncommand:'#{command}'\nstdout:#{stdout}\nstderr:#{stderr}"
  raise error_message unless status.to_i.zero?

  stdout
end

namespace :waffle do
  desc "provision machines - vmpooler eg 'bundle exec rake 'provision[ubuntu-1604-x86_64]'"
  task :provision, [:provisioner, :platform] do |_task, args|
    include SolidWaffle
    Rake::Task['spec_prep'].invoke
    config_data = { 'modulepath' => File.join(Dir.pwd, 'spec', 'fixtures', 'modules') }
    raise "waffle_provision was not found in #{config_data['modulepath']}, please amend the .fixtures.yml file" unless File.directory?(File.join(config_data['modulepath'], 'waffle_provision'))

    if args[:provisioner] == 'vmpooler'
      params = { 'action' => 'provision', 'platform' => args[:platform], 'inventory' => Dir.pwd }
      result = run_task('waffle_provision::vmpooler', 'localhost', params, config: config_data, inventory: nil)
      puts result
    elsif args[:provisioner] == 'docker'
      params = { 'action' => 'provision', 'platform' => args[:platform], 'inventory' => Dir.pwd }
      result = run_task('waffle_provision::docker', 'localhost', params, config: config_data, inventory: nil)
      puts result
    else
      raise "Unknown provisioner '#{args[:provisioner]}', try docker/vmpooler"
    end
  end

  desc 'install puppet agent, [:hostname, :collection]'
  task :install_agent, [:hostname, :collection] do |_task, args|
    puts 'install_agent'
    include BoltSpec::Run
    inventory_hash = inventory_hash_from_inventory_file
    targets = find_targets(inventory_hash, args[:hostname])
    Rake::Task['spec_prep'].invoke
    config_data = { 'modulepath' => File.join(Dir.pwd, 'spec', 'fixtures', 'modules') }
    params = if args[:collection].nil?
               nil
             else
               "collection=#{args[:collection]}"
             end
    raise "puppet_agent was not found in #{config_data['modulepath']}, please amend the .fixtures.yml file" unless File.directory?(File.join(config_data['modulepath'], 'puppet_agent'))

    result = run_task('puppet_agent::install', targets, params, config: config_data, inventory: inventory_hash)
    puts result
    # fix the path on ssh_nodes
    run_command('sed -i \'s!^\(\s*PATH=\)[^"]*"!\1"/opt/puppetlabs/puppet/bin:!\' /etc/environment', 'ssh_nodes', config: nil, inventory: inventory_hash) unless inventory_hash['groups'].select { |group| group['name'] == 'ssh_nodes' }.size.zero?
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
    if result.is_a?(Array)
      result.each do |node|
        puts "#{node['node']} failed #{node['result']}" if node['status'] != 'success'
      end
    else
      raise "Failed trying to run '#{install_module_command}' against inventory."
    end
    puts 'Installed'
  end

  desc 'tear-down - decommission machines'
  task :tear_down, [:target] do |_task, args|
    Rake::Task['spec_prep'].invoke
    config_data = { 'modulepath' => File.join(Dir.pwd, 'spec', 'fixtures', 'modules') }
    raise "waffle_provision was not found in #{config_data['modulepath']}, please amend the .fixtures.yml file" unless File.directory?(File.join(config_data['modulepath'], 'waffle_provision'))

    inventory_hash = inventory_hash_from_inventory_file
    targets = find_targets(inventory_hash, args[:target])
    targets.each do |node_name|
      # how do we know what provisioner to use
      node_facts = facts_from_node(inventory_hash, node_name)
      case node_facts['provisioner']
      when %r{vmpooler}
        params = { 'action' => 'tear_down', 'node_name' => node_name, 'inventory' => Dir.pwd }
        result = run_task('waffle_provision::vmpooler', 'localhost', params, config: config_data, inventory: nil)
        puts result
      when %r{docker}
        params = { 'action' => 'tear_down', 'node_name' => node_name, 'inventory' => Dir.pwd }
        result = run_task('waffle_provision::docker', 'localhost', params, config: config_data, inventory: nil)
        puts result
      end
    end
  end
end

if File.file?('inventory.yaml')
  namespace :acceptance do
    include SolidWaffle
    inventory_hash = inventory_hash_from_inventory_file
    hosts = find_targets(inventory_hash, nil)
    desc 'Run serverspec against all hosts'
    task all: hosts
    hosts.each do |host|
      desc "Run serverspec against #{host}"
      RSpec::Core::RakeTask.new(host.to_sym) do |t|
        t.pattern = 'spec/acceptance/**{,/*/**}/*_spec.rb'
        ENV['TARGET_HOST'] = host
      end
    end
  end
end
