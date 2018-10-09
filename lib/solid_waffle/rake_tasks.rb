# frozen_string_literal: true

require 'solid_waffle'
require 'bolt_spec/run'
include SolidWaffle

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
    inventory_hash = { 'groups' =>
  [{ 'name' => 'ssh_nodes',
     'groups' => [{ 'name' => 'default', 'nodes' => [hostname] }],
     'config' => { 'transport' => 'ssh', 'ssh' => { 'host-key-check' => false } } }] }
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
  end

  desc 'pre-test - build and install module'
  task :pre_test, [:hostname] do |_task, args|
    puts 'pre_test'
    include BoltSpec::Run
    `pdk build  --force`
    puts 'built'
    inventory_hash = load_inventory_hash
    targets = find_targets(args[:hostname], inventory_hash)
    module_tar = Dir.glob('pkg/*.tar.gz').max_by { |f| File.mtime(f) }
    result = `bundle exec bolt file upload #{module_tar} /tmp/#{File.basename(module_tar)} --nodes ssh_nodes --no-host-key-check --inventoryfile inventory.yaml`
    puts result
    result = run_command("/opt/puppetlabs/puppet/bin/puppet module install /tmp/#{File.basename(module_tar)}", targets, config: nil, inventory: inventory_hash)
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
  end
end
