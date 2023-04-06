# frozen_string_literal: true

require 'spec_helper'
require 'support/inventory'

RSpec.describe PuppetLitmus::InventoryManipulation do
  let(:inventory_full_path) { 'spec/data/inventory.yaml' }

  context 'with config_from_node' do
    it 'no matching node, returns nil' do
      expect(config_from_node(config_hash, 'not.here')).to be_nil
    end

    it 'no config section, returns nil' do
      expect(config_from_node(no_config_hash, 'test.delivery.puppetlabs.net')).to be_nil
    end

    it 'config exists, and returns' do
      expect(config_from_node(config_hash, 'test.delivery.puppetlabs.net')).to eq('transport' => 'ssh', 'ssh' => { 'user' => 'root', 'password' => 'Qu@lity!', 'host-key-check' => false })
    end

    it 'facts exists, and returns' do
      expect(facts_from_node(config_hash, 'test.delivery.puppetlabs.net')).to eq('provisioner' => 'vmpooler', 'platform' => 'centos-5-x86_64')
    end

    it 'vars exists, and returns' do
      expect(vars_from_node(config_hash, 'test.delivery.puppetlabs.net')).to eq('role' => 'agent')
    end

    it 'no feature exists for the group, and returns hash with feature added' do
      expect(add_feature_to_group(no_feature_hash, 'puppet-agent', 'ssh_nodes')).to eq('groups' => [{ 'features' => ['puppet-agent'], 'name' => 'ssh_nodes', 'targets' => [{ 'config' => { 'ssh' => { 'host-key-check' => false, 'password' => 'Qu@lity!', 'user' => 'root' }, 'transport' => 'ssh' }, 'facts' => { 'platform' => 'centos-5-x86_64', 'provisioner' => 'vmpooler' }, 'uri' => 'test.delivery.puppetlabs.net' }] }, { 'name' => 'winrm_nodes', 'targets' => [] }]) # rubocop:disable Layout/LineLength: Line is too long
    end

    it 'feature exists for the group, and returns hash with feature removed' do
      expect(remove_feature_from_group(feature_hash_group, 'puppet-agent', 'ssh_nodes')).to eq('groups' => [{ 'features' => [], 'name' => 'ssh_nodes', 'targets' => [{ 'config' => { 'ssh' => { 'host-key-check' => false, 'password' => 'Qu@lity!', 'user' => 'root' }, 'transport' => 'ssh' }, 'facts' => { 'platform' => 'centos-5-x86_64', 'provisioner' => 'vmpooler' }, 'uri' => 'test.delivery.puppetlabs.net' }] }, { 'name' => 'winrm_nodes', 'targets' => [] }]) # rubocop:disable Layout/LineLength: Line is too long
    end

    it 'write from inventory_hash to inventory_yaml file feature_hash_group' do
      expect { write_to_inventory_file(feature_hash_group, inventory_full_path) }.not_to raise_error
    end

    it 'empty feature exists for the group, and returns hash with feature added' do
      expect(add_feature_to_group(empty_feature_hash_group, 'puppet-agent', 'ssh_nodes')).to eq('groups' => [{ 'features' => ['puppet-agent'], 'name' => 'ssh_nodes', 'targets' => [{ 'config' => { 'ssh' => { 'host-key-check' => false, 'password' => 'Qu@lity!', 'user' => 'root' }, 'transport' => 'ssh' }, 'facts' => { 'platform' => 'centos-5-x86_64', 'provisioner' => 'vmpooler' }, 'uri' => 'test.delivery.puppetlabs.net' }] }, { 'name' => 'winrm_nodes', 'targets' => [] }]) # rubocop:disable Layout/LineLength: Line is too long
    end

    it 'no feature exists for the node, and returns hash with feature added' do
      expect(add_feature_to_node(no_feature_hash, 'puppet-agent', 'test.delivery.puppetlabs.net')).to eq('groups' => [{ 'name' => 'ssh_nodes', 'targets' => [{ 'config' => { 'ssh' => { 'host-key-check' => false, 'password' => 'Qu@lity!', 'user' => 'root' }, 'transport' => 'ssh' }, 'facts' => { 'platform' => 'centos-5-x86_64', 'provisioner' => 'vmpooler' }, 'uri' => 'test.delivery.puppetlabs.net', 'features' => ['puppet-agent'] }] }, { 'name' => 'winrm_nodes', 'targets' => [] }]) # rubocop:disable Layout/LineLength: Line is too long
    end

    it 'feature exists for the node, and returns hash with feature removed' do
      expect(remove_feature_from_node(feature_hash_node, 'puppet-agent', 'test.delivery.puppetlabs.net')).to eq('groups' => [{ 'name' => 'ssh_nodes', 'targets' => [{ 'config' => { 'ssh' => { 'host-key-check' => false, 'password' => 'Qu@lity!', 'user' => 'root' }, 'transport' => 'ssh' }, 'facts' => { 'platform' => 'centos-5-x86_64', 'provisioner' => 'vmpooler' }, 'uri' => 'test.delivery.puppetlabs.net', 'features' => [] }] }, { 'name' => 'winrm_nodes', 'targets' => [] }]) # rubocop:disable Layout/LineLength: Line is too long
    end

    it 'write from inventory_hash to inventory_yaml file feature_hash_node' do
      expect { write_to_inventory_file(feature_hash_node, inventory_full_path) }.not_to raise_error
    end

    it 'empty feature exists for the node, and returns hash with feature added' do
      expect(add_feature_to_node(empty_feature_hash_node, 'puppet-agent', 'test.delivery.puppetlabs.net')).to eq('groups' => [{ 'name' => 'ssh_nodes', 'targets' => [{ 'config' => { 'ssh' => { 'host-key-check' => false, 'password' => 'Qu@lity!', 'user' => 'root' }, 'transport' => 'ssh' }, 'facts' => { 'platform' => 'centos-5-x86_64', 'provisioner' => 'vmpooler' }, 'uri' => 'test.delivery.puppetlabs.net', 'features' => ['puppet-agent'] }] }, { 'name' => 'winrm_nodes', 'targets' => [] }]) # rubocop:disable Layout/LineLength: Line is too long
    end

    it 'write from inventory_hash to inventory_yaml file no feature_hash' do
      expect(File).to exist(inventory_full_path)
      expect { write_to_inventory_file(no_feature_hash, inventory_full_path) }.not_to raise_error
    end

    it 'group does not exist in inventory, and returns hash with group added' do
      expect(add_node_to_group(no_docker_hash, foo_node, 'docker_nodes')).to eq('groups' =>
        [{ 'name' => 'ssh_nodes', 'targets' => [] }, { 'name' => 'winrm_nodes', 'targets' => [] }, { 'name' => 'docker_nodes', 'targets' => [foo_node] }])
    end

    it 'group exists in inventory, and returns hash with node added' do
      expect(add_node_to_group(no_docker_hash, foo_node, 'ssh_nodes')).to eq('groups' =>
        [{ 'name' => 'ssh_nodes', 'targets' => [foo_node] }, { 'name' => 'winrm_nodes', 'targets' => [] }])
    end
  end

  context 'with target searching' do
    it 'gets correct groups names from an inventory' do
      expect(groups_in_inventory(complex_inventory)).to eql(%w[ssh_nodes frontend winrm_nodes])
    end

    it 'applies a code block to groups' do
      counts = groups_in_inventory(complex_inventory) do |group|
        if group.key? 'targets'
          group['targets'].count
        end
      end
      expect(counts.sum).to be 4
    end

    it 'gets names of targets' do
      target_list = ['test.delivery.puppetlabs.net', 'test2.delivery.puppetlabs.net', 'test3.delivery.puppetlabs.net', 'test4.delivery.puppetlabs.net']
      expect(targets_in_inventory(complex_inventory)).to eql target_list
    end

    it 'applies a code block to targets' do
      target_list = targets_in_inventory(complex_inventory) do |target|
        next unless target['config']['transport'] == 'winrm'

        target['uri']
      end

      expect(target_list).to eql ['test4.delivery.puppetlabs.net']
    end

    it 'returns agent nodes' do
      node_list = nodes_with_role('agent', complex_inventory)
      expected_node_list = ['test.delivery.puppetlabs.net', 'test3.delivery.puppetlabs.net', 'test4.delivery.puppetlabs.net']
      expect(node_list).to eql expected_node_list
    end

    it 'returns agent nodes with different capitolization' do
      node_list = nodes_with_role('Agent', complex_inventory)
      expected_node_list = ['test.delivery.puppetlabs.net', 'test3.delivery.puppetlabs.net', 'test4.delivery.puppetlabs.net']
      expect(node_list).to eql expected_node_list
    end

    it 'searches for a group' do
      expect(search_for_target('winrm_nodes', complex_inventory)).to eql ['winrm_nodes']
    end

    it 'seaches for an array of groups' do
      expect(search_for_target(%w[winrm_nodes ssh_nodes], complex_inventory)).to eql %w[winrm_nodes ssh_nodes]
    end

    it 'searches for a specific target' do
      expect(search_for_target('test.delivery.puppetlabs.net', complex_inventory)).to eql ['test.delivery.puppetlabs.net']
    end

    it 'searches for an array of roles' do
      expect(search_for_target(%w[iis nginx], complex_inventory)).to eql ['test4.delivery.puppetlabs.net', 'test3.delivery.puppetlabs.net']
    end

    it 'searches for roles as symbols' do
      expect(search_for_target([:iis, :nginx], complex_inventory)).to eql ['test4.delivery.puppetlabs.net', 'test3.delivery.puppetlabs.net']
    end

    it 'raises an error if target not found' do
      expect { search_for_target(:blah, complex_inventory) }.to raise_error 'targets not found in inventory'
    end
  end
end
