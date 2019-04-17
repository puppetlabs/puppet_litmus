# frozen_string_literal: true

# helper functions for manipulating and reading a bolt inventory file
module PuppetLitmus::InventoryManipulation
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

  def find_targets(inventory_hash, targets)
    if targets.nil?
      inventory = Bolt::Inventory.new(inventory_hash, nil)
      targets = inventory.node_names.to_a
    else
      targets = [targets]
    end
    targets
  end

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

  def facts_from_node(inventory_hash, node_name)
    inventory_hash['groups'].each do |group|
      group['nodes'].each do |node|
        if node['name'] == node_name
          return node['facts']
        end
      end
    end
    raise "No config was found for #{node_name}"
  end

  def add_node_to_group(inventory_hash, node_name, group_name)
    inventory_hash['groups'].each do |group|
      if group['name'] == group_name
        group['nodes'].push node_name
      end
    end
    inventory_hash
  end

  def remove_node(inventory_hash, node_name)
    inventory_hash['groups'].each do |group|
      group['nodes'].delete_if { |i| i['name'] == node_name }
    end
    inventory_hash
  end
end
