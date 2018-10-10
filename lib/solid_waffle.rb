# frozen_string_literal: true

require 'pry'
require 'bolt_spec/run'

# Helper methods for testing puppet content
module SolidWaffle
  include BoltSpec::Run
  def apply_manifest(manifest, _fuckit)
    inventory_hash = load_inventory_hash
    host = ENV['TARGET_HOST']
    result = run_command("/opt/puppetlabs/puppet/bin/puppet apply -e '#{manifest}'", host, config: nil, inventory: inventory_hash)
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
end
