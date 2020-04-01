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
      .with(File.join(default_modulepath, 'provision'))
      .and_return(true)
    allow_any_instance_of(BoltSpec::Run).to receive(:run_task)
      .with("provision::#{provisioner}", 'localhost', params, config: { 'modulepath' => default_modulepath }, inventory: nil)
      .and_return(results)
    result = described_class.provision(provisioner, platform, inventory_vars)
    expect(result).to eq(results)
  end
end

RSpec.describe PuppetLitmus::RakeHelper do
  let(:default_modulepath) { File.join(Dir.pwd, 'spec', 'fixtures', 'modules') }

  context 'with provision_list' do
    let(:provision_hash) { { 'default' => { 'provisioner' => 'docker', 'images' => ['waffleimage/centos7'] } } }
    let(:results) { [] }

    it 'calls function' do
      expect(described_class).to receive(:provision).with('docker', 'waffleimage/centos7', nil).and_return(results)
      described_class.provision_list(provision_hash, 'default')
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
        params: { 'action' => 'provision', 'platform' => 'waffleimage/centos7', 'inventory' => Dir.pwd },
      },
      {
        provisioner: 'vagrant',
        platform: 'centos7',
        inventory_vars: nil,
        provision_hash: { 'default' => { 'provisioner' => 'vagrant', 'images' => ['centos7'] } },
        results: [],
        params: { 'action' => 'provision', 'platform' => 'centos7', 'inventory' => Dir.pwd },
      },
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
    let(:params) { { 'action' => 'tear_down', 'node_name' => 'some.host', 'inventory' => Dir.pwd } }

    it 'calls function' do
      allow(File).to receive(:directory?).with(File.join(default_modulepath, 'provision')).and_return(true)
      allow_any_instance_of(BoltSpec::Run).to receive(:run_task).with('provision::docker', 'localhost', params, config: { 'modulepath' => default_modulepath }, inventory: nil).and_return([])
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
      allow(File).to receive(:directory?).with(File.join(default_modulepath, 'puppet_agent')).and_return(true)
      allow_any_instance_of(BoltSpec::Run).to receive(:run_task).with(
        'puppet_agent::install',
        targets,
        params,
        config: { 'modulepath' => default_modulepath },
        inventory: inventory_hash,
      ).and_return([])
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
    let(:uninstall_module_command) { 'puppet module uninstall foo --force' }
    let(:install_module_command) { "puppet module install --module_repository 'https://forgeapi.puppetlabs.com' #{module_tar}" }

    it 'calls function' do
      allow_any_instance_of(BoltSpec::Run).to receive(:upload_file).with(module_tar, module_tar, targets, options: {}, config: nil, inventory: inventory_hash).and_return([])
      allow(File).to receive(:exist?).with(File.join(Dir.pwd, 'metadata.json')).and_return(true)
      allow(File).to receive(:read).with(File.join(Dir.pwd, 'metadata.json')).and_return(JSON.dump({ name: 'foo' }))
      allow(Open3).to receive(:capture3).with("bundle exec bolt file upload \"#{module_tar}\" /tmp/#{File.basename(module_tar)} --targets all --inventoryfile inventory.yaml")
                                        .and_return(['success', '', 0])
      allow_any_instance_of(BoltSpec::Run).to receive(:run_command).with(uninstall_module_command, targets, config: nil, inventory: inventory_hash).and_return([])
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
      described_class.check_connectivity?(inventory_hash, 'some.host')
    end

    it 'node unavailable' do
      allow_any_instance_of(BoltSpec::Run).to receive(:run_command).with(command, targets, config: nil, inventory: inventory_hash).and_return([{ 'target' => 'some.host', 'status' => 'failure' }])
      expect { described_class.check_connectivity?(inventory_hash, 'some.host') }.to raise_error(RuntimeError, %r{Connectivity has failed on:})
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

  context 'with provisioner_task' do
    described_class::SUPPORTED_PROVISIONERS.each do |supported_provisioner|
      it "returns supported provisioner task name for #{supported_provisioner}" do
        expect(described_class.provisioner_task(supported_provisioner)).to eq("provision::#{supported_provisioner}")
      end
    end

    it 'returns an unsupported provisioner name' do
      expect(described_class.provisioner_task('my_org::custom_provisioner')).to eql('my_org::custom_provisioner')
    end
  end
end
