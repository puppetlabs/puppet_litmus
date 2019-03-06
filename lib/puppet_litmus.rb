# frozen_string_literal: true

require 'pry'
require 'bolt_spec/run'

# Helper methods for testing puppet content
module PuppetLitmus
  include BoltSpec::Run
  def apply_manifest(manifest, opts = {}, manifest_file_location = nil)
    target_node_name = ENV['TARGET_HOST']
    raise 'manifest and manifest_file_location are mutually exclusive arguments, pick one' if !manifest.nil? && !manifest_file_location.nil?

    manifest_file_location = create_manifest_file(manifest) if !manifest.nil? && manifest_file_location.nil?
    inventory_hash = if target_node_name.nil? || target_node_name == 'localhost'
                       nil
                     else
                       inventory_hash_from_inventory_file
                     end
    command_to_run = "puppet apply #{manifest_file_location}"
    command_to_run += " --modulepath #{Dir.pwd}/spec/fixtures/modules" if target_node_name.nil? || target_node_name == 'localhost'
    command_to_run += ' --detailed-exitcodes' if !opts[:catch_changes].nil? && (opts[:catch_changes] == true)
    # BOLT-608
    if Gem.win_platform?
      stdout, stderr, status = Open3.capture3(command_to_run)
      status_text = if status.to_i.zero?
                      'success'
                    else
                      'failure'
                    end
      result = [{ 'node' => 'localhost', 'status' => status_text, 'result' => { 'exit_code' => status.to_i, 'stderr' => stderr, 'stdout' => stdout } }]
    else
      result = run_command(command_to_run, target_node_name, config: nil, inventory: inventory_hash)
    end

    raise "apply mainfest failed\n`#{command_to_run}`\n======\n#{result}" if result.first['result']['exit_code'] != 0 && opts[:expect_failures] != true

    result
  end

  # creates a temp manifest file locally & remote depending on target
  def create_manifest_file(manifest)
    target_node_name = ENV['TARGET_HOST']
    manifest_file = Tempfile.new(['manifest_', '.pp'])
    manifest_file.write(manifest)
    manifest_file.close
    if target_node_name.nil? || target_node_name == 'localhost'
      # no need to transfer
      manifest_file_location = manifest_file.path
    else
      # transfer to TARGET_HOST
      command = "bundle exec bolt file upload #{manifest_file.path} /tmp/#{File.basename(manifest_file)} --nodes #{target_node_name} --inventoryfile inventory.yaml"
      stdout, stderr, status = Open3.capture3(command)
      error_message = "Attempted to run\ncommand:'#{command}'\nstdout:#{stdout}\nstderr:#{stderr}"
      raise error_message unless status.to_i.zero?

      manifest_file_location = "/tmp/#{File.basename(manifest_file)}"
    end
    manifest_file_location
  end

  def apply_manifest_and_idempotent(manifest)
    manifest_file_location = create_manifest_file(manifest)
    apply_manifest(nil, { catch_failures: true }, manifest_file_location)
    apply_manifest(nil, { catch_changes: true }, manifest_file_location)
  end

  def run_shell(command_to_run, opts = {})
    inventory_hash = inventory_hash_from_inventory_file
    target_node_name = ENV['TARGET_HOST']
    result = run_command(command_to_run, target_node_name, config: nil, inventory: inventory_hash)

    raise "shell failed\n`#{command_to_run}`\n======\n#{result}" if result.first['result']['exit_code'] != 0 && opts[:expect_failures] != true

    result
  end

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

  # Runs a selected task against the target host. Parameters should be passed in with a hash format.
  def task_run(task_name, params)
    config_data = { 'modulepath' => File.join(Dir.pwd, 'spec', 'fixtures', 'modules') }
    inventory_hash = inventory_hash_from_inventory_file
    target_node_name = ENV['TARGET_HOST'] if target_node_name.nil?

    result = run_task(task_name, target_node_name, params, config: config_data, inventory: inventory_hash)

    raise "task failed\n`#{task_name}`\n======\n#{result}" if result.first['status'] != 'success'

    result
  end
end
