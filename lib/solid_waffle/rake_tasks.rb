# frozen_string_literal: true

require 'rspec/core/rake_task'
require 'solid_waffle'
require 'bolt_spec/run'
require 'open3'

def install_ssh_components(platform, container)
  case platform
  when %r{ubuntu}, %r{debian}
    `docker exec #{container} apt-get update`
    `docker exec #{container} apt-get install -y openssh-server openssh-client vim`
  when %r{cumulus}
    `docker exec #{container} apt-get update`
    `docker exec #{container} apt-get install -y openssh-server openssh-client`
  when %r{fedora-(2[2-9])}
    `docker exec #{container} dnf clean all`
    `docker exec #{container} dnf install -y sudo openssh-server openssh-clients`
    `docker exec #{container} ssh-keygen -t rsa -f /etc/ssh/ssh_host_rsa_key`
    `docker exec #{container} ssh-keygen -t dsa -f /etc/ssh/ssh_host_dsa_key`
  when %r{^el-}, %r{centos}, %r{fedora}, %r{redhat}, %r{eos}
    `docker exec #{container} yum clean all`
    `docker exec #{container} yum install -y sudo openssh-server openssh-clients`
    `docker exec #{container} ssh-keygen -t rsa -f /etc/ssh/ssh_host_rsa_key`
    `docker exec #{container} ssh-keygen -t dsa -f /etc/ssh/ssh_host_dsa_key`
  when %r{opensuse}, %r{sles}
    `docker exec #{container} zypper -n in openssh`
    `docker exec #{container} ssh-keygen -t rsa -f /etc/ssh/ssh_host_rsa_key`
    `docker exec #{container} ssh-keygen -t dsa -f /etc/ssh/ssh_host_dsa_key`
    `docker exec #{container} sed -ri 's/^#?UsePAM .*/UsePAM no/' /etc/ssh/sshd_config`
  when %r{archlinux}
    `docker exec #{container} pacman --noconfirm -Sy archlinux-keyring`
    `docker exec #{container} pacman --noconfirm -Syu`
    `docker exec #{container} pacman -S --noconfirm openssh`
    `docker exec #{container} ssh-keygen -A`
    `docker exec #{container} sed -ri 's/^#?UsePAM .*/UsePAM no/' /etc/ssh/sshd_config`
    `docker exec #{container} systemctl enable sshd`
  else
    raise "platform #{platform} not yet supported on docker"
  end

  # Make sshd directory, set root password
  `docker exec #{container} mkdir -p /var/run/sshd`
  `docker exec #{container} bash -c 'echo root:root | /usr/sbin/chpasswd'`
end

def fix_ssh(container)
  `docker exec #{container} sed -ri 's/^#?PermitRootLogin .*/PermitRootLogin yes/' /etc/ssh/sshd_config`
  `docker exec #{container} sed -ri 's/^#?PasswordAuthentication .*/PasswordAuthentication yes/' /etc/ssh/sshd_config`
  `docker exec #{container} sed -ri 's/^#?UseDNS .*/UseDNS no/' /etc/ssh/sshd_config`
  `docker exec #{container} service ssh restart`
end

def platform_uses_ssh(platform)
  uses_ssh = if platform !~ %r{win-}
               true
             else
               false
             end
  uses_ssh
end

namespace :waffle do
  desc "provision machines - vmpooler eg `bundle exec rake 'provision[ubuntu-1604-x86_64]`"
  task :provision, [:provisioner, :platform] do |_task, args|
    include SolidWaffle
    inventory_hash = if File.file?('inventory.yaml')
                       load_inventory_hash
                     else
                       { 'groups' => [{ 'name' => 'ssh_nodes', 'nodes' => [] }, { 'name' => 'winrm_nodes', 'nodes' => [] }] }
                     end
    if args[:provisioner] == 'vmpooler'
      # vmpooler
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
      if platform_uses_ssh(platform)
        node = { 'name' => hostname, 'config' => { 'transport' => 'ssh', 'ssh' => { 'host-key-check' => false } } }
        group_name = 'ssh_nodes'
      else
        node = { 'name' => hostname, 'config' => { 'transport' => 'winrm', 'winrm' => { 'user' => 'Administrator', 'password' => 'Qu@lity!', 'ssl' => false } } }
        group_name = 'winrm_nodes'
      end
    elsif args[:provisioner] == 'docker'
      warn '!!! Using private port forwarding!!!'
      platform, version = args[:platform].split(':')
      front_facing_port = 2222
      full_container_name = "#{platform}_#{version}-#{front_facing_port}"
      (front_facing_port..2230).each do |i|
        front_facing_port = i
        full_container_name = "#{platform}_#{version}-#{front_facing_port}"
        _stdout, stderr, _status = Open3.capture3("docker port #{full_container_name}")
        break unless (stderr =~ %r{No such container}i).nil?
        raise 'All front facing ports are in use.' if front_facing_port == 2230
      end
      puts "Provisioning #{full_container_name}"
      _stdout, _stderr, _status = Open3.capture3("docker run -d -it -p #{front_facing_port}:22 --name #{full_container_name} #{args[:platform]}")
      install_ssh_components(platform, full_container_name)
      fix_ssh(full_container_name)
      hostname = 'localhost'
      node = { 'name' => "#{hostname}:#{front_facing_port}", 'config' => { 'transport' => 'ssh', 'ssh' => { 'user' => 'root', 'password' => 'root', 'port' => front_facing_port, 'host-key-check' => false } } }
      group_name = 'ssh_nodes'
      inventory_hash
    else
      raise "Unknown provisioner '#{args[:provisioner]}', try docker/vmpooler"
    end
    add_node_to_group(inventory_hash, node, group_name)
    File.open('inventory.yaml', 'w') { |f| f.write inventory_hash.to_yaml }
  end

  desc 'pre_setup - disable apt / configure firewall'
  task :pre_setup do
    puts 'pre_setup'
  end

  desc 'install puppet agent, [:hostname, :collection]'
  task :install_agent, [:hostname, :collection] do |_task, args|
    puts 'install_agent'
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
  task :tear_down, [:provisioner, :platform] do |_task, _args|
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
  namespace :acceptance do
    include SolidWaffle
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
