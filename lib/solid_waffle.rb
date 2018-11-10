# frozen_string_literal: true

require 'pry'
require 'bolt_spec/run'

# Helper methods for testing puppet content
module SolidWaffle
  include BoltSpec::Run
  def apply_manifest(manifest, opts = {})
    inventory_hash = load_inventory_hash
    host = ENV['TARGET_HOST']

    file = Tempfile.new('foo')
    file.write(manifest)
    file.close
    `bundle exec bolt file upload #{file.path} /tmp/#{File.basename(file)} --nodes #{host} --inventoryfile inventory.yaml`
    # result = run_command("puppet apply -e 'include motd'", host, config: nil, inventory: inventory_hash)
    command_to_run = "puppet apply /tmp/#{File.basename(file)}"
    command_to_run += ' --detailed-exitcodes' if !opts[:catch_changes].nil? && (opts[:catch_changes] == true)
    result = run_command(command_to_run, host, config: nil, inventory: inventory_hash)

    raise "apply mainfest failed\n`#{command_to_run}`\n======\n#{result}" if result.first['result']['exit_code'] != 0

    result
  end

  def load_inventory_hash
    filename = 'inventory.yaml'
    raise 'There is no inventory file' unless File.exist?(filename)

    inventory_hash = YAML.load_file(filename)
    inventory_hash
  end

  def find_targets(targets, inventory_hash)
    if targets.nil?
      inventory = Bolt::Inventory.new(inventory_hash, nil)
      targets = inventory.node_names.to_a
    else
      targets = [targets]
    end
    targets
  end

  def host_in_group(inventory_hash, host, group_name)
    exists = false
    inventory_hash['groups'].each do |group|
      next unless group['name'] == group_name

      group['nodes'].each do |node|
        exists = true if node['name'] == host
      end
    end
    exists
  end

  def config_from_node(inventory_hash, host)
    inventory_hash['groups'].each do |group|
      group['nodes'].each do |node|
        if node['name'] == host
          return node['config']
        end
      end
    end
    raise "No config was found for #{host}"
  end

  def remove_node(inventory_hash, node_name)
    inventory_hash['groups'].each do |group|
      group['nodes'].delete_if {|i| i['name'] == node_name}
    end
    inventory_hash
  end
end
