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

  desc 'install puppet - PE / FOSS / Bolt'
  task :install_puppet, [:hostname] do |_task, args|
    puts 'install_puppet'
    include BoltSpec::Run
    inventory_hash = load_inventory_hash
    targets = find_targets(args[:hostname], inventory_hash)

    result = run_command('wget https://apt.puppetlabs.com/puppet5-release-xenial.deb', targets, config: nil, inventory: inventory_hash)
    puts result
    result = run_command('dpkg -i puppet5-release-xenial.deb', targets, config: nil, inventory: inventory_hash)
    puts result
    result = run_command('apt update', targets, config: nil, inventory: inventory_hash)
    puts result
    result = run_command('apt-get install puppet-agent -y', targets, config: nil, inventory: inventory_hash)
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
    module_tar = Dir.glob("pkg/*.tar.gz").max_by {|f| File.mtime(f)}
    if targets.is_a?(Array)
      targets.each do |target|
        `scp #{module_tar} root@#{target}:/tmp`
      end
    end
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
