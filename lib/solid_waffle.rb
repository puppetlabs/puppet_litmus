# frozen_string_literal: true

require 'pry'
require 'bolt_spec/run'

# Helper methods for testing puppet content
module SolidWaffle
  include BoltSpec::Run
  def apply_manifest(manifest, opts = {})
    inventory_hash = inventory_hash_from_inventory_file
    target_node_name = ENV['TARGET_HOST']

    manifest_file = Tempfile.new('foo')
    manifest_file.write(manifest)
    manifest_file.close
    command = "bundle exec bolt file upload #{manifest_file.path} /tmp/#{File.basename(manifest_file)} --nodes #{target_node_name} --inventoryfile inventory.yaml"
    stdout, stderr, status = Open3.capture3(command)
    error_message = "Attempted to run\ncommand:'#{command}'\nstdout:#{stdout}\nstderr:#{stderr}"
    raise error_message unless status.to_i.zero?

    # result = run_command("puppet apply -e 'include motd'", host, config: nil, inventory: inventory_hash)
    command_to_run = "puppet apply /tmp/#{File.basename(manifest_file)}"
    command_to_run += ' --detailed-exitcodes' if !opts[:catch_changes].nil? && (opts[:catch_changes] == true)
    result = run_command(command_to_run, target_node_name, config: nil, inventory: inventory_hash)

    raise "apply mainfest failed\n`#{command_to_run}`\n======\n#{result}" if result.first['result']['exit_code'] != 0

    result
  end

  def inventory_hash_from_inventory_file
    filename = 'inventory.yaml'
    raise 'There is no inventory file' unless File.exist?(filename)

    inventory_hash = YAML.load_file(filename)
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
