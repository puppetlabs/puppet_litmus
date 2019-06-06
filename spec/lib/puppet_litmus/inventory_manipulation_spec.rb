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
  end
end
