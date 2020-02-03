# frozen_string_literal: true

require 'spec_helper'

load File.expand_path('../../../lib/puppet_litmus/rake_helper.rb', __dir__)

RSpec.describe PuppetLitmus::RakeHelper do
  context 'with provision_list' do
    let(:provision_hash) { { 'default' => { 'provisioner' => 'docker', 'images' => ['waffleimage/centos7'] } } }
    let(:results) { [] }

    it 'calls function' do
      expect(described_class).to receive(:provision).with('docker', 'waffleimage/centos7', nil).and_return(results)
      described_class.provision_list(provision_hash, 'default')
    end
  end

  context 'with provision' do
    let(:provision_hash) { { 'default' => { 'provisioner' => 'docker', 'images' => ['waffleimage/centos7'] } } }
    let(:results) { [] }
    let(:params) { { 'action' => 'provision', 'platform' => 'waffleimage/centos7', 'inventory' => Dir.pwd } }

    it 'calls function' do
      allow(File).to receive(:directory?).and_call_original
      allow(File).to receive(:directory?).with(File.join(DEFAULT_CONFIG_DATA['modulepath'], 'provision')).and_return(true)
      allow_any_instance_of(BoltSpec::Run).to receive(:run_task).with('provision::docker', 'localhost', params, config: DEFAULT_CONFIG_DATA, inventory: nil).and_return(results)
      described_class.provision('docker', 'waffleimage/centos7', nil)
    end
  end

  context 'with tear_down' do
    let(:inventory_hash) do
      { 'groups' =>
        [{ 'name' => 'ssh_nodes', 'targets' =>
          [{ 'uri' => 'some.host', 'facts' => { 'provisioner' => 'docker', 'container_name' => 'foo', 'platform' => 'some.host' } }] }] }
    end
    let(:targets) { ['some.host'] }
    let(:params) { { 'action' => 'tear_down', 'node_name' => 'some.host', 'inventory' => Dir.pwd } }

    it 'calls function' do
      allow(File).to receive(:directory?).with(File.join(DEFAULT_CONFIG_DATA['modulepath'], 'provision')).and_return(true)
      allow_any_instance_of(BoltSpec::Run).to receive(:run_task).with('provision::docker', 'localhost', params, config: DEFAULT_CONFIG_DATA, inventory: nil).and_return([])
      described_class.tear_down_nodes(targets, inventory_hash)
    end
  end

  context 'with install_agent' do
    let(:inventory_hash) do
      { 'groups' =>
        [{ 'name' => 'ssh_nodes', 'targets' =>
          [{ 'uri' => 'some.host', 'facts' => { 'provisioner' => 'docker', 'container_name' => 'foo', 'platform' => 'some.host' } }] }] }
    end
    let(:targets) { ['some.host'] }
    let(:params) { { 'collection' => 'puppet6' } }

    it 'calls function' do
      allow(File).to receive(:directory?).with(File.join(DEFAULT_CONFIG_DATA['modulepath'], 'puppet_agent')).and_return(true)
      allow_any_instance_of(BoltSpec::Run).to receive(:run_task).with('puppet_agent::install', targets, params, config: DEFAULT_CONFIG_DATA, inventory: inventory_hash).and_return([])
      described_class.install_agent('puppet6', targets, inventory_hash)
    end
  end

  context 'with install_module' do
    let(:inventory_hash) do
      { 'version' => 2,
        'groups' =>
        [{ 'name' => 'ssh_nodes', 'targets' =>
          [{ 'uri' => 'some.host', 'facts' => { 'provisioner' => 'docker', 'container_name' => 'foo', 'platform' => 'some.host' } }] }] }
    end
    let(:module_tar) { '/tmp/foo.tar.gz' }
    let(:targets) { ['some.host'] }
    let(:install_module_command) { "puppet module install /tmp/#{File.basename(module_tar)}" }

    it 'calls function' do
      allow(Open3).to receive(:capture3).with("bundle exec bolt file upload \"#{module_tar}\" /tmp/#{File.basename(module_tar)} --nodes all --inventoryfile inventory.yaml")
                                        .and_return(['success', '', 0])
      allow_any_instance_of(BoltSpec::Run).to receive(:run_command).with(install_module_command, targets, config: nil, inventory: inventory_hash).and_return([])
      described_class.install_module(inventory_hash, nil, module_tar)
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
      described_class.check_connectivity?(inventory_hash, nil)
    end

    it 'node unavailable' do
      allow_any_instance_of(BoltSpec::Run).to receive(:run_command).with(command, targets, config: nil, inventory: inventory_hash).and_return([{ 'target' => 'some.host', 'status' => 'failure' }])
      expect { described_class.check_connectivity?(inventory_hash, nil) }.to raise_error(RuntimeError, %r{Connectivity has failed on:})
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
      expect(described_class).to receive(:metadata_module_name).and_return('foo-bar')
      described_class.uninstall_module(inventory_hash, nil)
    end

    it 'and custom name' do
      allow_any_instance_of(BoltSpec::Run).to receive(:run_command).with(uninstall_module_command, targets, config: nil, inventory: inventory_hash).and_return([])
      described_class.uninstall_module(inventory_hash, nil, 'foo-bar')
    end
  end

  context 'with module name' do
    let(:metadata) { '{ "name" : "foo-bar" }' }

    it 'reads module name' do
      allow(File).to receive(:exist?).with(File.join(Dir.pwd, 'metadata.json')).and_return(true)
      allow(File).to receive(:read).with(File.join(Dir.pwd, 'metadata.json')).and_return(metadata)
      name = described_class.metadata_module_name
      expect(name).to eq('foo-bar')
    end
  end
end
