# frozen_string_literal: true

require 'spec_helper'

RSpec.describe PuppetLitmus::InventoryManipulation do
  class DummyClass
  end
  let(:dummy_class) do
    dummy_class = DummyClass.new
    dummy_class.extend(described_class)
    dummy_class
  end

  context 'with config_from_node' do
    let(:no_config_hash) do
      { 'groups' =>
  [{ 'name' => 'ssh_nodes',
     'nodes' =>
     [{ 'name' => 'test.delivery.puppetlabs.net',
        'facts' => { 'provisioner' => 'vmpooler', 'platform' => 'centos-5-x86_64' } }] },
   { 'name' => 'winrm_nodes', 'nodes' => [] }] }
    end

    let(:config_hash) do
      { 'groups' =>
  [{ 'name' => 'ssh_nodes',
     'nodes' =>
     [{ 'name' => 'test.delivery.puppetlabs.net',
        'config' => { 'transport' => 'ssh', 'ssh' => { 'user' => 'root', 'password' => 'Qu@lity!', 'host-key-check' => false } },
        'facts' => { 'provisioner' => 'vmpooler', 'platform' => 'centos-5-x86_64' } }] },
   { 'name' => 'winrm_nodes', 'nodes' => [] }] }
    end

    let(:inventory_full_path) { 'spec/data/inventory.yaml' }

    let(:no_feature_hash) do
      { 'groups' =>
  [{ 'name' => 'ssh_nodes',
     'nodes' =>
     [{ 'name' => 'test.delivery.puppetlabs.net',
        'config' => { 'transport' => 'ssh', 'ssh' => { 'user' => 'root', 'password' => 'Qu@lity!', 'host-key-check' => false } },
        'facts' => { 'provisioner' => 'vmpooler', 'platform' => 'centos-5-x86_64' } }] },
   { 'name' => 'winrm_nodes', 'nodes' => [] }] }
    end

    let(:feature_hash) do
      { 'groups' =>
  [{ 'name' => 'ssh_nodes',
     'nodes' =>
     [{ 'name' => 'test.delivery.puppetlabs.net',
        'config' => { 'transport' => 'ssh', 'ssh' => { 'user' => 'root', 'password' => 'Qu@lity!', 'host-key-check' => false } },
        'facts' => { 'provisioner' => 'vmpooler', 'platform' => 'centos-5-x86_64' } }],
     'features' => ['puppet-agent'] },
   { 'name' => 'winrm_nodes', 'nodes' => [] }] }
    end

    let(:empty_feature_hash) do
      { 'groups' =>
  [{ 'name' => 'ssh_nodes',
     'nodes' =>
     [{ 'name' => 'test.delivery.puppetlabs.net',
        'config' => { 'transport' => 'ssh', 'ssh' => { 'user' => 'root', 'password' => 'Qu@lity!', 'host-key-check' => false } },
        'facts' => { 'provisioner' => 'vmpooler', 'platform' => 'centos-5-x86_64' } }],
     'features' => [] },
   { 'name' => 'winrm_nodes', 'nodes' => [] }] }
    end

    it 'no matching node, raises' do
      expect { dummy_class.config_from_node(config_hash, 'not.here') }.to raise_error('No config was found for not.here')
    end

    it 'no config section, returns nil' do
      expect(dummy_class.config_from_node(no_config_hash, 'test.delivery.puppetlabs.net')).to eq(nil)
    end

    it 'config exists, and returns' do
      expect(dummy_class.config_from_node(config_hash, 'test.delivery.puppetlabs.net')).to eq('transport' => 'ssh', 'ssh' =>
{ 'user' => 'root', 'password' => 'Qu@lity!', 'host-key-check' => false })
    end

    it 'no feature exists, and returns hash with feature added' do
      expect(dummy_class.add_feature_to_group(no_feature_hash, 'puppet-agent', 'ssh_nodes')).to eq('groups' => [{ 'features' => ['puppet-agent'], 'name' => 'ssh_nodes', 'nodes' => [{ 'config' => { 'ssh' => { 'host-key-check' => false, 'password' => 'Qu@lity!', 'user' => 'root' }, 'transport' => 'ssh' }, 'facts' => { 'platform' => 'centos-5-x86_64', 'provisioner' => 'vmpooler' }, 'name' => 'test.delivery.puppetlabs.net' }] }, { 'name' => 'winrm_nodes', 'nodes' => [] }]) # rubocop:disable Metrics/LineLength: Line is too long
    end

    it 'feature exists, and returns hash with feature removed' do
      expect(dummy_class.remove_feature_from_group(feature_hash, 'puppet-agent', 'ssh_nodes')).to eq('groups' => [{ 'features' => [], 'name' => 'ssh_nodes', 'nodes' => [{ 'config' => { 'ssh' => { 'host-key-check' => false, 'password' => 'Qu@lity!', 'user' => 'root' }, 'transport' => 'ssh' }, 'facts' => { 'platform' => 'centos-5-x86_64', 'provisioner' => 'vmpooler' }, 'name' => 'test.delivery.puppetlabs.net' }] }, { 'name' => 'winrm_nodes', 'nodes' => [] }]) # rubocop:disable Metrics/LineLength: Line is too long
    end

    it 'write from inventory_hash to inventory_yaml file feature_hash' do
      expect { dummy_class.write_to_inventory_file(feature_hash, inventory_full_path) }.not_to raise_error
    end

    it 'empty feature exists, and returns hash with feature added' do
      expect(dummy_class.add_feature_to_group(empty_feature_hash, 'puppet-agent', 'ssh_nodes')).to eq('groups' => [{ 'features' => ['puppet-agent'], 'name' => 'ssh_nodes', 'nodes' => [{ 'config' => { 'ssh' => { 'host-key-check' => false, 'password' => 'Qu@lity!', 'user' => 'root' }, 'transport' => 'ssh' }, 'facts' => { 'platform' => 'centos-5-x86_64', 'provisioner' => 'vmpooler' }, 'name' => 'test.delivery.puppetlabs.net' }] }, { 'name' => 'winrm_nodes', 'nodes' => [] }]) # rubocop:disable Metrics/LineLength: Line is too long
    end

    it 'write from inventory_hash to inventory_yaml file no feature_hash' do
      expect(File).to exist(inventory_full_path)
      expect { dummy_class.write_to_inventory_file(no_feature_hash, inventory_full_path) }.not_to raise_error
    end
  end
end
