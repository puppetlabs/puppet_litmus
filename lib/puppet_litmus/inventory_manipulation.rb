# frozen_string_literal: true

module PuppetLitmus; end # rubocop:disable Style/Documentation

# helper functions for manipulating and reading a bolt inventory file
module PuppetLitmus::InventoryManipulation
  # Creates an inventory hash from the inventory.yaml.
  #
  # @param inventory_full_path [String] path to the litmus_inventory.yaml file
  # @return [Hash] hash of the litmus_inventory.yaml file.
  def inventory_hash_from_inventory_file(inventory_full_path = nil)
    require 'yaml'
    inventory_full_path = "#{Dir.pwd}/spec/fixtures/litmus_inventory.yaml" if inventory_full_path.nil?
    raise "There is no inventory file at '#{inventory_full_path}'." unless File.exist?(inventory_full_path)

    YAML.load_file(inventory_full_path)
  end

  # Provide a default hash for executing against localhost
  #
  # @return [Hash] inventory.yaml hash containing only an entry for localhost
  def localhost_inventory_hash
    {
      'groups' => [
        {
          'name' => 'local',
          'targets' => [
            {
              'uri' => 'litmus_localhost',
              'config' => { 'transport' => 'local' },
              'feature' => 'puppet-agent'
            }
          ]
        }
      ]
    }
  end

  # Finds targets to perform operations on from an inventory hash.
  #
  # @param inventory_hash [Hash] hash of the inventory.yaml file
  # @param targets [Array]
  # @return [Array] array of targets.
  def find_targets(inventory_hash, targets)
    if targets.nil?
      inventory_hash.to_s.scan(/uri"=>"(\S*)"/).flatten
    else
      [targets]
    end
  end

  # Recursively find and iterate over the groups in an inventory. If no block is passed
  # to the function then only the name of the group is returned. If a block is passed
  # then the block is executed against each group and the value of the block is returned.
  #
  # @param inventory_hash [Hash] Inventory hash from inventory.yaml
  # @param block [Block] Block to execute against each node
  def groups_in_inventory(inventory_hash, &block)
    inventory_hash['groups'].flat_map do |group|
      output_collector = []
      output_collector << if block
                            yield group
                          else
                            group['name'].downcase
                          end
      output_collector << groups_in_inventory({ 'groups' => group['groups'] }, &block) if group.key? 'groups'
      output_collector.flatten.compact
    end
  end

  # Iterate over all targets in an inventory. If no block is given to the function
  # it will return the name of every target in the inventory. If a block is passed
  # it will execute the block on each target and return the value of the block.
  #
  # @param inventory_hash [Hash] Inventory hash from inventory.yaml
  # @param block [Block] Block to execute against each node
  def targets_in_inventory(inventory_hash)
    groups_in_inventory(inventory_hash) do |group|
      if group.key? 'targets'
        group['targets'].map do |target|
          if block_given?
            (yield target)
          else
            target['uri'].downcase
          end
        end
      end
    end
  end

  # Find all targets in an inventory that have a role. The roles for a target are
  # specified in the vars hash for a target. This function is tolerant to the roles
  # hash being called either 'role' or 'roles' and it is tolerant to the roles being
  # either a single key value or an array of roles.
  #
  # @param role [String] The name of a role to search for
  # @param inventory [Hash] Inventory hash from inventory.yaml
  def nodes_with_role(role, inventory)
    output_collector = []
    targets_in_inventory(inventory) do |target|
      vars = target['vars']
      roles = [vars['role'] || vars['roles']].flatten
      roles = roles.map(&:downcase)
      output_collector << target['uri'] if roles.include? role.downcase
    end
    output_collector unless output_collector.empty?
  end

  # Searches through the inventory hash to either validate that a group being targeted exists,
  # validate that a specific target being targeted exists, or resolves role names to a
  # list of nodes to target. Targets and roles can be specified as strings or as symbols, and
  # the functions are tolerant to incorrect capitalization.
  #
  # @param target [String] || [Array[String]] A list of targets
  # @param inventory [Hash] inventory hash from inventory.yaml
  def search_for_target(target, inventory)
    result_collector = []
    groups = groups_in_inventory(inventory)
    Array(target).map do |name|
      result_collector << name if groups.include? name.to_s.downcase
      result_collector << name if targets_in_inventory(inventory).include? name.to_s.downcase
      result_collector << nodes_with_role(name.to_s, inventory)
    end

    result_collector = result_collector.flatten.compact
    raise 'targets not found in inventory' if result_collector.empty?

    result_collector
  end

  # Determines if a node_name exists in a group in the inventory_hash.
  #
  # @param inventory_hash [Hash] hash of the inventory.yaml file
  # @param node_name [String] node to locate in the group
  # @param group_name [String] group of nodes to limit the search for the node_name in
  # @return [Boolean] true if node_name exists in group_name.
  def target_in_group(inventory_hash, node_name, group_name)
    exists = false
    inventory_hash['groups'].each do |group|
      next unless group['name'] == group_name

      group['targets'].each do |node|
        exists = true if node['uri'] == node_name
      end
    end
    exists
  end

  # Determines if a node_name exists in the inventory_hash.
  #
  # @param inventory_hash [Hash] hash of the inventory.yaml file
  # @param node_name [String] node to locate in the group
  # @return [Boolean] true if node_name exists in the inventory_hash.
  def target_in_inventory?(inventory_hash, node_name)
    find_targets(inventory_hash, nil).include?(node_name)
  end

  # Finds a config hash in the inventory hash by searching for a node name.
  #
  # @param inventory_hash [Hash] hash of the inventory.yaml file
  # @param node_name [String] node to locate in the group
  # @return [Hash] config for node of name node_name
  def config_from_node(inventory_hash, node_name)
    config = targets_in_inventory(inventory_hash) do |target|
      next unless target['uri'].casecmp(node_name).zero?

      return target['config'] unless target['config'].nil?
    end

    config.empty? ? nil : config[0]
  end

  # Finds a facts hash in the inventory hash by searching for a node name.
  #
  # @param inventory_hash [Hash] hash of the inventory.yaml file
  # @param node_name [String] node to locate in the group
  # @return [Hash] facts for node of name node_name
  def facts_from_node(inventory_hash, node_name)
    facts = targets_in_inventory(inventory_hash) do |target|
      next unless target['uri'].casecmp(node_name).zero?

      target['facts'] unless target['facts'].nil?
    end

    facts.empty? ? nil : facts[0]
  end

  # Finds a var hash in the inventory hash by searching for a node name.
  #
  # @param inventory_hash [Hash] hash of the inventory.yaml file
  # @param node_name [String] node to locate in the group
  # @return [Hash] vars for node of name node_name
  def vars_from_node(inventory_hash, node_name)
    vars = targets_in_inventory(inventory_hash) do |target|
      next unless target['uri'].casecmp(node_name).zero?

      target['vars'] unless target['vars'].nil?
    end
    vars.empty? ? {} : vars[0]
  end

  # Adds a node to a group specified, if group_name exists in inventory hash.
  #
  # @param inventory_hash [Hash] hash of the inventory.yaml file
  # @param node [Hash] node to add to the group
  # group_name [String] group of nodes to limit the search for the node_name in
  # @return [Hash] inventory_hash with node added to group if group_name exists in inventory hash.
  def add_node_to_group(inventory_hash, node, group_name)
    # check if group exists
    if inventory_hash['groups'].any? { |g| g['name'] == group_name }
      inventory_hash['groups'].each do |group|
        group['targets'].push node if group['name'] == group_name
      end
    else
      # add new group
      group = { 'name' => group_name, 'targets' => [node] }
      inventory_hash['groups'].push group
    end
    inventory_hash
  end

  # Removes named node from a group inside an inventory_hash.
  #
  # @param inventory_hash [Hash] hash of the inventory.yaml file
  # @param node_name [String] node to locate in the group
  # @return [Hash] inventory_hash with node of node_name removed.
  def remove_node(inventory_hash, node_name)
    inventory_hash['groups'].each do |group|
      group['targets'].delete_if { |i| i['uri'] == node_name }
    end
    inventory_hash
  end

  # Adds a feature to the group specified/
  #
  # @param inventory_hash [Hash] hash of the inventory.yaml file
  # @param feature_name [String] feature to locate in the group
  # group_name [String] group of nodes to limit the search for the group_name in
  # @return inventory.yaml file with feature added to group.
  # @return [Hash] inventory_hash with feature added to group if group_name exists in inventory hash.
  def add_feature_to_group(inventory_hash, feature_name, group_name)
    i = 0
    inventory_hash['groups'].each do |group|
      if group['name'] == group_name
        group = group.merge('features' => []) if group['features'].nil? == true
        group['features'].push feature_name unless group['features'].include?(feature_name)
        inventory_hash['groups'][i] = group
      end
      i += 1
    end
    inventory_hash
  end

  # Removes a feature from the group specified/
  #
  # @param inventory_hash [Hash] hash of the inventory.yaml file
  # @param feature_name [String] feature to locate in the group
  # group_name [String] group of nodes to limit the search for the group_name in
  # @return inventory.yaml file with feature removed from the group.
  # @return [Hash] inventory_hash with feature added to group if group_name exists in inventory hash.
  def remove_feature_from_group(inventory_hash, feature_name, group_name)
    inventory_hash['groups'].each do |group|
      group['features'].delete(feature_name) if group['name'] == group_name && group['features'].nil? != true
    end
    inventory_hash
  end

  # Adds a feature to the node specified/
  #
  # @param inventory_hash [Hash] hash of the inventory.yaml file
  # @param feature_name [String] feature to locate in the node
  # node_name [String] node of nodes to limit the search for the node_name in
  # @return inventory.yaml file with feature added to node.
  # @return [Hash] inventory_hash with feature added to node if node_name exists in inventory hash.
  def add_feature_to_node(inventory_hash, feature_name, node_name)
    group_index = 0
    inventory_hash['groups'].each do |group|
      node_index = 0
      group['targets'].each do |node|
        if node['uri'] == node_name
          node = node.merge('features' => []) if node['features'].nil? == true
          node['features'].push feature_name unless node['features'].include?(feature_name)
          inventory_hash['groups'][group_index]['targets'][node_index] = node
        end
        node_index += 1
      end
      group_index += 1
    end
    inventory_hash
  end

  # Removes a feature from the node specified/
  #
  # @param inventory_hash [Hash] hash of the inventory.yaml file
  # @param feature_name [String] feature to locate in the node
  # @param node_name [String] node of nodes to limit the search for the node_name in
  # @return inventory.yaml file with feature removed from the node.
  # @return [Hash] inventory_hash with feature added to node if node_name exists in inventory hash.
  def remove_feature_from_node(inventory_hash, feature_name, node_name)
    inventory_hash['groups'].each do |group|
      group['targets'].each do |node|
        node['features'].delete(feature_name) if node['uri'] == node_name && node['features'].nil? != true
      end
    end
    inventory_hash
  end

  # Write inventory_hash to inventory_yaml file/
  #
  #  @param inventory_full_path [String] path to the inventory.yaml file
  #  @param inventory_hash [Hash] hash of the inventory.yaml file
  #  @return inventory.yaml file with feature added to group.
  def write_to_inventory_file(inventory_hash, inventory_full_path)
    File.open(inventory_full_path, 'wb+') { |f| f.write(inventory_hash.to_yaml) }
  end

  # Add the `litmus.platform` with platform information for the target
  #
  # @param inventory_hash [Hash] hash of the inventory.yaml file
  # @param node_name [String] node of nodes to limit the search for the node_name in
  def add_platform_field(inventory_hash, node_name)
    facts_from_node(inventory_hash, node_name)
  rescue StandardError => e
    warn e
    {}
  end
end
