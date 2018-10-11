# frozen_string_literal: true

require 'rspec/core/rake_task'
require 'solid_waffle'
require 'bolt_spec/run'
include SolidWaffle

def vmpooler_platform_uses_ssh(platform)
  uses_ssh = if platform !~ %r{win-}
               true
             else
               false
             end
  uses_ssh
end

def vmpooler_inventory_add_group(platform, hostname)
  inventory_hash = if vmpooler_platform_uses_ssh(platform)
                     { 'name' => 'ssh_nodes',
                       'groups' => [{ 'name' => 'ssh_agents', 'nodes' => [hostname] }],
                       'config' => { 'transport' => 'ssh', 'ssh' => { 'host-key-check' => false } } }
                   else
                     { 'name' => 'win_rm_nodes',
                       'groups' => [{ 'name' => 'win_agents', 'nodes' => [hostname] }],
                       'config' => { 'transport' => 'winrm', 'winrm' => { 'user' => 'Administrator', 'password' => 'Qu@lity!', 'ssl' => false } } }
                   end
  inventory_hash
end

def vmpooler_add_to_inventory_hash(inventory_hash, platform, hostname)
  group_found = false
  group_name = if vmpooler_platform_uses_ssh(platform)
                 'ssh_nodes'
               else
                 'win_rm_nodes'
               end
  inventory_hash['groups'].each do |group|
    if group['name'] == group_name
      group['groups'].first['nodes'].push(hostname)
      group_found = true
    end
  end
  inventory_hash['groups'].push(vmpooler_inventory_add_group(platform, hostname)) unless group_found
end

namespace :waffle do
  desc "provision machines - vmpooler eg `bundle exec rake 'provision[ubuntu-1604-x86_64]`"
  task :provision, [:platform] do |_task, args|
    platform = if args[:platform].nil?
                 'ubuntu-1604-x86_64'
               else
                 args[:platform]
               end
    puts "Using VMPooler for #{platform}"
    vmpooler = Net::HTTP.start(ENV['VMPOOLER_HOST'] || 'vmpooler.delivery.puppetlabs.net')

    reply = vmpooler.post("/api/v1/vm/#{platform}", '')
    raise "Error: #{reply}: #{reply.message}" unless reply.is_a?(Net::HTTPSuccess)

    data = JSON.parse(reply.body)
    raise "VMPooler is not ok: #{data.inspect}" unless data['ok'] == true

    hostname = "#{data[platform]['hostname']}.#{data['domain']}"
    puts "reserved #{hostname} in vmpooler"
    if File.file?('inventory.yaml')
      puts 'adding'
      inventory_hash = load_inventory_hash
      vmpooler_add_to_inventory_hash(inventory_hash, platform, hostname)
    else
      inventory_hash = { 'groups' => [vmpooler_inventory_add_group(platform, hostname)] }
    end
    File.open('inventory.yaml', 'w') { |f| f.write inventory_hash.to_yaml }
  end

  desc 'pre_setup - disable apt / configure firewall'
  task :pre_setup do
    puts 'pre_setup'
  end

  desc 'install puppet agent, [:hostname, :collection]'
  task :install_puppet, [:hostname, :collection] do |_task, args|
    puts 'install_puppet'
    include BoltSpec::Run
    inventory_hash = load_inventory_hash
    targets = find_targets(args[:hostname], inventory_hash)
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
  task :install_module, [:hostname] do |_task, args|
    puts 'pre_test'
    include BoltSpec::Run
    `pdk build  --force`
    puts 'built'
    inventory_hash = load_inventory_hash
    targets = find_targets(args[:hostname], inventory_hash)
    module_tar = Dir.glob('pkg/*.tar.gz').max_by { |f| File.mtime(f) }
    result = `bundle exec bolt file upload #{module_tar} /tmp/#{File.basename(module_tar)} --nodes all --inventoryfile inventory.yaml`
    puts result
    result = run_command("puppet module install /tmp/#{File.basename(module_tar)}", targets, config: nil, inventory: inventory_hash)
    puts result
  end

  desc 'snapshot - allow rollbacks in vmpooler / vagrant'
  task :snapshot do
    puts 'snapshot'
  end
  desc 'test - run rspec / inspec / serverspec / puppet code as tests'
  task :test do
    puts 'test'
  end
  desc 'tear-down - decommission machines'
  task :tear_down do
    puts 'tear_down'
    inventory_hash = load_inventory_hash
    hosts = find_targets(nil, inventory_hash)
    hosts.each do |host|
      result = `curl -X DELETE --url http://vcloud.delivery.puppetlabs.net/vm/#{host}`
      puts result
    end
  end
end

if File.file?('inventory.yaml')
  namespace :serverspec do
    inventory_hash = load_inventory_hash
    hosts = find_targets(nil, inventory_hash)
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
