# frozen_string_literal: true

require 'spec_helper'

RSpec.shared_examples 'supported provisioner' do |args|
  let(:provisioner) { args[:provisioner] }
  let(:platform) { args[:platform] }
  let(:inventory_vars) { args[:inventory_vars] }
  let(:provision_hash) { args[:provision_hash] }
  let(:results) { args[:results] }
  let(:params) { args[:params] }

  it 'calls function' do
    allow(File).to receive(:directory?).and_call_original
    allow(File).to receive(:directory?)
      .with(File.join(described_class::DEFAULT_CONFIG_DATA['modulepath'], 'provision'))
      .and_return(true)
    allow_any_instance_of(BoltSpec::Run).to receive(:run_task)
      .with("provision::#{provisioner}", 'localhost', params, config: described_class::DEFAULT_CONFIG_DATA, inventory: nil)
      .and_return(results)
    result = provision(provisioner, platform, inventory_vars)
    expect(result).to eq(results)
  end
end

RSpec.describe PuppetLitmus::RakeHelper do
  inventory_file = File.join(Dir.pwd, 'spec', 'fixtures', 'litmus_inventory.yaml')
  let(:inventory_file) { inventory_file }

  context 'with provision_list' do
    let(:provision_hash) { { 'default' => { 'provisioner' => 'docker', 'images' => ['waffleimage/centos7'] } } }
    let(:results) { [] }

    it 'calls function' do
      expect(self).to receive(:provision).with('docker', 'waffleimage/centos7', nil).and_return(results)
      provision_list(provision_hash, 'default')
    end
  end

  context 'with provision' do
    examples = [
      {
        provisioner: 'docker',
        platform: 'waffleimage/centos7',
        inventory_vars: nil,
        provision_hash: { 'default' => { 'provisioner' => 'docker', 'images' => ['waffleimage/centos7'] } },
        results: [],
        params: { 'action' => 'provision', 'platform' => 'waffleimage/centos7', 'inventory' => inventory_file }
      },
      {
        provisioner: 'vagrant',
        platform: 'centos7',
        inventory_vars: nil,
        provision_hash: { 'default' => { 'provisioner' => 'vagrant', 'images' => ['centos7'] } },
        results: [],
        params: { 'action' => 'provision', 'platform' => 'centos7', 'inventory' => inventory_file }
      },
      {
        provisioner: 'lxd',
        platform: 'images:centos/7',
        inventory_vars: nil,
        provision_hash: { 'default' => { 'provisioner' => 'lxd', 'images' => ['images:centos/7'] } },
        results: [],
        params: { 'action' => 'provision', 'platform' => 'images:centos/7', 'inventory' => inventory_file }
      }
    ].freeze

    examples.each do |e|
      describe e[:provisioner] do
        it_behaves_like 'supported provisioner', e
      end
    end
  end

  context 'with tear_down' do
    let(:inventory_hash) do
      { 'groups' =>
        [{ 'name' => 'ssh_nodes', 'targets' =>
          [{ 'uri' => 'some.host', 'facts' => { 'provisioner' => 'docker', 'container_name' => 'foo', 'platform' => 'some.host' } }] }] }
    end
    let(:targets) { ['some.host'] }
    let(:params) { { 'action' => 'tear_down', 'node_name' => 'some.host', 'inventory' => inventory_file } }

    it 'calls function' do
      allow(File).to receive(:directory?).with(File.join(described_class::DEFAULT_CONFIG_DATA['modulepath'], 'provision')).and_return(true)
      allow_any_instance_of(BoltSpec::Run).to receive(:run_task).with('provision::docker', 'localhost', params, config: described_class::DEFAULT_CONFIG_DATA, inventory: nil).and_return([])
      tear_down_nodes(targets, inventory_hash)
    end
  end

  context 'with bulk tear_down' do
    let(:inventory_hash) do
      { 'groups' =>
        [{ 'name' => 'ssh_nodes', 'targets' =>
          [
            { 'uri' => 'one.host', 'facts' => { 'provisioner' => 'abs', 'platform' => 'ubuntu-1604-x86_64', 'job_id' => 'iac-task-pid-21648' } },
            { 'uri' => 'two.host', 'facts' => { 'provisioner' => 'abs', 'platform' => 'ubuntu-1804-x86_64', 'job_id' => 'iac-task-pid-21648' } },
            { 'uri' => 'three.host', 'facts' => { 'provisioner' => 'abs', 'platform' => 'ubuntu-2004-x86_64', 'job_id' => 'iac-task-pid-21648' } },
            { 'uri' => 'four.host', 'facts' => { 'provisioner' => 'abs', 'platform' => 'ubuntu-2004-x86_64', 'job_id' => 'iac-task-pid-21649' } }
          ] }] }
    end
    let(:targets) { ['one.host'] }
    let(:params) { { 'action' => 'tear_down', 'node_name' => 'one.host', 'inventory' => inventory_file } }

    it 'calls function' do
      allow(File).to receive(:directory?).with(File.join(described_class::DEFAULT_CONFIG_DATA['modulepath'], 'provision')).and_return(true)
      allow_any_instance_of(BoltSpec::Run).to receive(:run_task).with('provision::abs', 'localhost', params, config: described_class::DEFAULT_CONFIG_DATA, inventory: nil).and_return(
        [{ 'target' => 'localhost',
           'action' => 'task',
           'object' => 'provision::abs',
           'status' => 'success',
           'value' =>
           { 'status' => 'ok',
             'removed' =>
             ['one.host',
              'two.host',
              'three.host'] } }]
      )
      results = tear_down_nodes(targets, inventory_hash)
      expect(results.keys).to eq(['one.host', 'two.host', 'three.host'])
      results.each_value do |value|
        expect(value[0]['value']).to eq({ 'status' => 'ok' })
      end
    end
  end

  context 'with install_agent' do
    let(:inventory_hash) do
      { 'groups' =>
        [{ 'name' => 'ssh_nodes', 'targets' =>
          [{ 'uri' => 'some.host', 'facts' => { 'provisioner' => 'docker', 'container_name' => 'foo', 'platform' => 'some.host' } }] }] }
    end
    let(:targets) { ['some.host'] }
    let(:token) { 'some_token' }
    let(:params) { { 'collection' => 'puppet6', 'password' => token } }

    it 'calls function' do
      allow(ENV).to receive(:fetch).with('PUPPET_VERSION', nil).and_return(nil)
      allow(ENV).to receive(:fetch).with('PUPPET_FORGE_TOKEN', nil).and_return(token)
      allow(File).to receive(:directory?).with(File.join(described_class::DEFAULT_CONFIG_DATA['modulepath'], 'puppet_agent')).and_return(true)
      allow_any_instance_of(BoltSpec::Run).to receive(:run_task).with('puppet_agent::install', targets, params, config: described_class::DEFAULT_CONFIG_DATA, inventory: inventory_hash).and_return([])
      install_agent('puppet6', targets, inventory_hash)
    end

    it 'adds puppet version' do
      params = { 'collection' => 'puppet7', 'version' => '7.35.0' }
      allow(ENV).to receive(:fetch).with('PUPPET_VERSION', nil).and_return('7.35.0')
      allow(ENV).to receive(:fetch).with('PUPPET_FORGE_TOKEN', nil).and_return(nil)
      allow(File).to receive(:directory?).with(File.join(described_class::DEFAULT_CONFIG_DATA['modulepath'], 'puppet_agent')).and_return(true)
      allow_any_instance_of(BoltSpec::Run).to receive(:run_task).with('puppet_agent::install', targets, params, config: described_class::DEFAULT_CONFIG_DATA, inventory: inventory_hash).and_return([])
      install_agent('puppet7', targets, inventory_hash)
    end

    it 'fails for puppetcore if no token supplied' do
      params = { 'collection' => 'puppetcore7' }
      allow(ENV).to receive(:fetch).with('PUPPET_VERSION', nil).and_return(nil)
      allow(ENV).to receive(:fetch).with('PUPPET_FORGE_TOKEN', nil).and_return(nil)
      allow(File).to receive(:directory?).with(File.join(described_class::DEFAULT_CONFIG_DATA['modulepath'], 'puppet_agent')).and_return(true)
      allow_any_instance_of(BoltSpec::Run).to receive(:run_task).with('puppet_agent::install', targets, params, config: described_class::DEFAULT_CONFIG_DATA, inventory: inventory_hash).and_return([])
      expect { install_agent('puppetcore7', targets, inventory_hash) }.to raise_error(RuntimeError, /puppetcore agent installs require a valid PUPPET_FORGE_TOKEN set in the env\./)
    end
  end

  context 'with install_module' do
    let(:inventory_hash) do
      { 'version' => 2,
        'groups' =>
        [{ 'name' => 'ssh_nodes', 'targets' =>
          [{ 'uri' => 'some.host', 'facts' => { 'provisioner' => 'docker', 'container_name' => 'foo', 'platform' => 'some.host' } }] }] }
    end
    let(:module_tar) { 'foo.tar.gz' }
    let(:targets) { ['some.host'] }
    let(:uninstall_module_command) { 'puppet module uninstall foo --force' }
    let(:install_module_command) { "puppet module install --module_repository 'https://forgeapi.example.com' #{module_tar}" }

    it 'calls function' do
      allow_any_instance_of(BoltSpec::Run).to receive(:upload_file).with(module_tar, module_tar, targets, options: {}, config: nil, inventory: inventory_hash).and_return([])
      allow(File).to receive(:exist?).with(File.join(Dir.pwd, 'metadata.json')).and_return(true)
      allow(File).to receive(:read).with(File.join(Dir.pwd, 'metadata.json')).and_return(JSON.dump({ name: 'foo' }))
      allow(Open3).to receive(:capture3).with("bundle exec bolt file upload \"#{module_tar}\" #{File.basename(module_tar)} --targets all --inventoryfile inventory.yaml")
                                        .and_return(['success', '', 0])
      allow_any_instance_of(BoltSpec::Run).to receive(:run_command).with(uninstall_module_command, targets, config: nil, inventory: inventory_hash).and_return([])
      allow_any_instance_of(BoltSpec::Run).to receive(:run_command).with(install_module_command, targets, config: nil, inventory: inventory_hash).and_return([])
      install_module(inventory_hash, nil, module_tar, 'https://forgeapi.example.com')
    end
  end

  context 'with check_connectivity' do
    let(:inventory_hash) do
      { 'groups' =>
        [{ 'name' => 'ssh_nodes', 'targets' =>
          [{ 'uri' => 'some.host', 'facts' => { 'provisioner' => 'docker', 'container_name' => 'foo', 'platform' => 'some.host' } }] }] }
    end
    let(:targets) { ['some.host'] }
    let(:command) { 'cd .' }

    it 'node available' do
      allow(Open3).to receive(:capture3).with('cd .').and_return(['success', '', 0])
      allow_any_instance_of(BoltSpec::Run).to receive(:run_command).with(command, targets, config: nil, inventory: inventory_hash).and_return([{ 'target' => 'some.host', 'status' => 'success' }])
      check_connectivity?(inventory_hash, 'some.host')
    end

    it 'node unavailable' do
      allow_any_instance_of(BoltSpec::Run).to receive(:run_command).with(command, targets, config: nil, inventory: inventory_hash).and_return([{ 'target' => 'some.host', 'status' => 'failure' }])
      expect { check_connectivity?(inventory_hash, 'some.host') }.to raise_error(RuntimeError, /Connectivity has failed on:/)
    end
  end

  context 'with uninstall module' do
    let(:inventory_hash) do
      { 'groups' =>
        [{ 'name' => 'ssh_nodes', 'targets' =>
          [{ 'uri' => 'some.host', 'facts' => { 'provisioner' => 'docker', 'container_name' => 'foo', 'platform' => 'some.host' } }] }] }
    end
    let(:targets) { ['some.host'] }
    let(:uninstall_module_command) { 'puppet module uninstall foo-bar' }

    it 'uninstalls module' do
      allow_any_instance_of(BoltSpec::Run).to receive(:run_command).with(uninstall_module_command, targets, config: nil, inventory: inventory_hash).and_return([])
      expect(self).to receive(:metadata_module_name).and_return('foo-bar')
      uninstall_module(inventory_hash, nil)
    end

    it 'and custom name' do
      allow_any_instance_of(BoltSpec::Run).to receive(:run_command).with(uninstall_module_command, targets, config: nil, inventory: inventory_hash).and_return([])
      uninstall_module(inventory_hash, nil, 'foo-bar')
    end
  end

  context 'with module name' do
    let(:metadata) { '{ "name" : "foo-bar" }' }

    it 'reads module name' do
      allow(File).to receive(:exist?).with(File.join(Dir.pwd, 'metadata.json')).and_return(true)
      allow(File).to receive(:read).with(File.join(Dir.pwd, 'metadata.json')).and_return(metadata)
      name = metadata_module_name
      expect(name).to eq('foo-bar')
    end
  end

  context 'with provisioner_task' do
    described_class::SUPPORTED_PROVISIONERS.each do |supported_provisioner|
      it "returns supported provisioner task name for #{supported_provisioner}" do
        expect(provisioner_task(supported_provisioner)).to eq("provision::#{supported_provisioner}")
      end
    end

    it 'returns an unsupported provisioner name' do
      expect(provisioner_task('my_org::custom_provisioner')).to eql('my_org::custom_provisioner')
    end
  end
end
