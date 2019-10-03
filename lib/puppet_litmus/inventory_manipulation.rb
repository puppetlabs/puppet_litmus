# frozen_string_literal: true

# helper functions for manipulating and reading a bolt inventory file
module PuppetLitmus::InventoryManipulation
  # Creates an inventory hash from the inventory.yaml.
  #
  # @param inventory_full_path [String] path to the inventory.yaml file
  # @return [Hash] hash of the inventory.yaml file.
  def inventory_hash_from_inventory_file(inventory_full_path = nil)
    inventory_full_path = if inventory_full_path.nil?
                            'inventory.yaml'
                          else
                            inventory_full_path
                          end
    raise "There is no inventory file at '#{inventory_full_path}'" unless File.exist?(inventory_full_path)

    inventory_hash = YAML.load_file(inventory_full_path)
    inventory_hash
  end

  # Provide a default hash for executing against localhost
  #
  # @return [Hash] inventory.yaml hash containing only an entry for localhost
  def localhost_inventory_hash
    {
      'groups' => [
        {
          'name' => 'local',
          'nodes' => [
            {
              'name' => 'litmus_localhost',
              'config' => { 'transport' => 'local' },
            },
          ],
        },
      ],
    }
  end

  # Finds targets to perform operations on from an inventory hash.
  #
  # @param inventory_hash [Hash] hash of the inventory.yaml file
  # @param targets [Array]
  # @return [Array] array of targets.
  def find_targets(inventory_hash, targets)
    if targets.nil?
      inventory = Bolt::Inventory.new(inventory_hash, nil)
      targets = inventory.node_names.to_a
    else
      targets = [targets]
    end
    targets
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

      group['nodes'].each do |node|
        exists = true if node['name'] == node_name
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
    inventory_hash['groups'].each do |group|
      group['nodes'].each do |node|
        if node['name'] == node_name
          return node['config']
        end
      end
    end
    raise "No config was found for #{node_name}"
  end

  # Finds a facts hash in the inventory hash by searching for a node name.
  #
  # @param inventory_hash [Hash] hash of the inventory.yaml file
  # @param node_name [String] node to locate in the group
  # @return [Hash] facts for node of name node_name
  def facts_from_node(inventory_hash, node_name)
    inventory_hash['groups'].each do |group|
      group['nodes'].each do |node|
        if node['name'] == node_name
          return node['facts']
        end
      end
    end
    raise "No facts were found for #{node_name}"
  end

  # Finds a var hash in the inventory hash by searching for a node name.
  #
  # @param inventory_hash [Hash] hash of the inventory.yaml file
  # @param node_name [String] node to locate in the group
  # @return [Hash] vars for node of name node_name
  def vars_from_node(inventory_hash, node_name)
    inventory_hash['groups'].each do |group|
      group['nodes'].each do |node|
        if node['name'] == node_name
          return node['vars']
        end
      end
    end
    {}
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
        if group['name'] == group_name
          group['nodes'].push node
        end
      end
    else
      # add new group
      group = { 'name' => group_name, 'nodes' => [node] }
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
      group['nodes'].delete_if { |i| i['name'] == node_name }
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
        if group['features'].nil? == true
          group = group.merge('features' => [])
        end
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
      if group['name'] == group_name && group['features'].nil? != true
        group['features'].delete(feature_name)
      end
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
      group['nodes'].each do |node|
        if node['name'] == node_name
          if node['features'].nil? == true
            node = node.merge('features' => [])
          end
          node['features'].push feature_name unless node['features'].include?(feature_name)
          inventory_hash['groups'][group_index]['nodes'][node_index] = node
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
  # node_name [String] node of nodes to limit the search for the node_name in
  # @return inventory.yaml file with feature removed from the node.
  # @return [Hash] inventory_hash with feature added to node if node_name exists in inventory hash.
  def remove_feature_from_node(inventory_hash, feature_name, node_name)
    inventory_hash['groups'].each do |group|
      group['nodes'].each do |node|
        if node['name'] == node_name && node['features'].nil? != true
          node['features'].delete(feature_name)
        end
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
    File.open(inventory_full_path, 'w+') { |f| f.write(inventory_hash.to_yaml) }
  end
end
