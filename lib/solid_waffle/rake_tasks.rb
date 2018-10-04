require 'solid_waffle'
require 'bolt_spec/run'

namespace :waffle do
  desc 'kittens in mittens'
  task :wtf do
    puts 'oi oi savaloy'
  end
  desc "provision machines - vmpooler eg `bundle exec rake 'provision[ubuntu-1604-x86_64]`"
  task :provision, [:platform] do |task, args|
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
  end
  desc 'pre_setup - disable apt / configure firewall'
  task :pre_setup do
    puts 'pre_setup'
  end
  desc 'install puppet - PE / FOSS / Bolt'
  task :install_puppet, [:hostname] do |task, args|
    puts 'install_puppet'
    config_data = {
        "ssh" =>  { "host-key-check" => false },
        "winrm" => { "ssl" => false } }
    include BoltSpec::Run
    result = run_command('wget https://apt.puppetlabs.com/puppet5-release-xenial.deb', args[:hostname], config: config_data)
  puts result
    result = run_command('dpkg -i puppet5-release-xenial.deb', args[:hostname], config: config_data)
  puts result
    result = run_command('apt update', args[:hostname], config: config_data)
  puts result
    result = run_command('apt-get install puppet-agent -y', args[:hostname], config: config_data)
  puts result
  end

  desc 'pre-test - build and install module'
  task :pre_test, [:hostname] do |task, args|
    puts 'pre_test'
    include BoltSpec::Run
    `pdk build  --force`
    puts 'built'
    config_data = {
        "ssh" =>  { "host-key-check" => false },
        "winrm" => { "ssl" => false } }
    `scp pkg/puppetlabs-motd-2.0.0.tar.gz root@#{args[:hostname]}:/tmp`
    result = run_command('/opt/puppetlabs/puppet/bin/puppet module install /tmp/puppetlabs-motd-2.0.0.tar.gz', args[:hostname], config: config_data)
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
