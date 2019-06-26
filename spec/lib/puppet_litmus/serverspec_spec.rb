# frozen_string_literal: true

require 'spec_helper'

RSpec.describe PuppetLitmus::Serverspec do
  class DummyClass
  end
  let(:dummy_class) do
    dummy_class = DummyClass.new
    dummy_class.extend(described_class)
    dummy_class
  end

  context 'with idempotent_apply' do
    let(:manifest) do
      "include '::doot'"
    end

    it 'calls all functions' do
      expect(dummy_class).to receive(:create_manifest_file).with(manifest).and_return('/bla.pp')
      expect(dummy_class).to receive(:apply_manifest).with(nil, catch_failures: true, manifest_file_location: '/bla.pp')
      expect(dummy_class).to receive(:apply_manifest).with(nil, catch_changes: true, manifest_file_location: '/bla.pp')
      dummy_class.idempotent_apply(manifest)
    end
  end

  describe '.run_shell' do
    let(:command_to_run) { "puts 'doot'" }
    let(:result) { ['result' => { 'exit_code' => 0, 'stdout' => nil, 'stderr' => nil }] }
    let(:inventory_hash) { Hash.new(0) }

    it 'responds to run_shell' do
      expect(dummy_class).to respond_to(:run_shell).with(1..2).arguments
    end

    context 'when running against localhost and no inventory.yaml file' do
      it 'does run_shell against localhost without error' do
        allow(ENV).to receive(:[]).with('TARGET_HOST').and_return('localhost')
        expect(dummy_class).to receive(:run_command).with(command_to_run, 'localhost', config: nil, inventory: nil).and_return(result)
        expect { dummy_class.run_shell(command_to_run) }.not_to raise_error
      end
    end

    context 'when running against remote host' do
      it 'does run_shell against remote host without error' do
        allow(ENV).to receive(:[]).with('TARGET_HOST').and_return('some.host')
        expect(dummy_class).to receive(:inventory_hash_from_inventory_file).and_return(inventory_hash)
        expect(dummy_class).to receive(:run_command).with(command_to_run, 'some.host', config: nil, inventory: inventory_hash).and_return(result)
        expect { dummy_class.run_shell(command_to_run) }.not_to raise_error
      end
    end
  end

  describe '.bolt_upload_file' do
    let(:local) { '/tmp' }
    let(:remote) { '/remote_tmp' }
    let(:result) { ['status' => 'success', 'result' => { 'exit_code' => 0, 'stdout' => nil, 'stderr' => nil }] }
    let(:inventory_hash) { Hash.new(0) }

    it 'responds to run_shell' do
      expect(dummy_class).to respond_to(:bolt_upload_file).with(2..3).arguments
    end

    context 'when running against remote host' do
      it 'does upload_file against remote host without error' do
        allow(ENV).to receive(:[]).with('TARGET_HOST').and_return('some.host')
        expect(dummy_class).to receive(:inventory_hash_from_inventory_file).and_return(inventory_hash)
        expect(dummy_class).to receive(:upload_file).with(local, remote, 'some.host', options: {}, config: nil, inventory: inventory_hash).and_return(result)
        expect { dummy_class.bolt_upload_file(local, remote) }.not_to raise_error
      end
    end

    context 'when running against remote host' do
      it 'does upload_file against localhost without error' do
        allow(ENV).to receive(:[]).with('TARGET_HOST').and_return('localhost')
        expect(dummy_class).not_to receive(:inventory_hash_from_inventory_file)
        expect(dummy_class).to receive(:upload_file).with(local, remote, 'localhost', options: {}, config: nil, inventory: nil).and_return(result)
        expect { dummy_class.bolt_upload_file(local, remote) }.not_to raise_error
      end
    end
  end

  describe '.bolt_run_script' do
    let(:script) { '/tmp/script.sh' }
    let(:result) { ['result' => { 'exit_code' => 0, 'stdout' => nil, 'stderr' => nil }] }
    let(:inventory_hash) { Hash.new(0) }

    it 'responds to bolt_run_script' do
      expect(dummy_class).to respond_to(:bolt_run_script).with(1..2).arguments
    end

    context 'when running against localhost and no inventory.yaml file' do
      it 'does bolt_run_script against localhost without error' do
        allow(ENV).to receive(:[]).with('TARGET_HOST').and_return('localhost')
        expect(dummy_class).not_to receive(:inventory_hash_from_inventory_file)
        expect(dummy_class).to receive(:run_script).with(script, 'localhost', [], options: {}, config: nil, inventory: nil).and_return(result)
        expect { dummy_class.bolt_run_script(script) }.not_to raise_error
      end
    end

    context 'when running against remote host' do
      it 'does bolt_run_script against remote host without error' do
        allow(ENV).to receive(:[]).with('TARGET_HOST').and_return('some.host')
        expect(dummy_class).to receive(:inventory_hash_from_inventory_file)
        expect(dummy_class).to receive(:run_script).with(script, 'some.host', [], options: {}, config: nil, inventory: nil).and_return(result)
        expect { dummy_class.bolt_run_script(script) }.not_to raise_error
      end
    end

    context 'when running with arguments' do
      it 'does bolt_run_script with arguments without error' do
        allow(ENV).to receive(:[]).with('TARGET_HOST').and_return('localhost')
        expect(dummy_class).not_to receive(:inventory_hash_from_inventory_file)
        expect(dummy_class).to receive(:run_script).with(script, 'localhost', ['doot'], options: {}, config: nil, inventory: nil).and_return(result)
        expect { dummy_class.bolt_run_script(script, arguments: ['doot']) }.not_to raise_error
      end
    end
  end

  describe '.run_bolt_task' do
    let(:task_name) { 'testtask' }
    let(:params) { { 'action' => 'install', 'name' => 'foo' } }
    let(:config_data) { { 'modulepath' => File.join(Dir.pwd, 'spec', 'fixtures', 'modules') } }
    let(:result_success) { ['status' => 'success', 'result' => { 'exit_code' => 0, 'stdout' => nil, 'stderr' => nil, 'result' => nil }] }
    let(:result_failure) { ['status' => 'failure', 'result' => { 'exit_code' => 255, 'stdout' => 'failure', 'stderr' => 'failure', 'result' => nil }] }
    let(:inventory_hash) { Hash.new(0) }

    it 'responds to bolt_run_task' do
      expect(dummy_class).to respond_to(:run_bolt_task).with(2..3).arguments
    end

    context 'when bolt returns success' do
      it 'does bolt_task_run gives no runtime error for success' do
        allow(ENV).to receive(:[]).with('TARGET_HOST').and_return('some.host')
        expect(dummy_class).to receive(:inventory_hash_from_inventory_file).and_return(inventory_hash)
        expect(dummy_class).to receive(:run_task).with(task_name, 'some.host', params, config: config_data, inventory: inventory_hash).and_return(result_success)
        expect { dummy_class.run_bolt_task(task_name, params, opts: {}) }.not_to raise_error
      end
    end

    context 'when bolt returns failure' do
      it 'does bolt_task_run gives runtime error for failure' do
        allow(ENV).to receive(:[]).with('TARGET_HOST').and_return('some.host')
        expect(dummy_class).to receive(:inventory_hash_from_inventory_file).and_return(inventory_hash)
        expect(dummy_class).to receive(:run_task).with(task_name, 'some.host', params, config: config_data, inventory: inventory_hash).and_return(result_failure)
        expect { dummy_class.run_bolt_task(task_name, params, opts: {}) }.to raise_error(RuntimeError, %r{task failed})
      end
    end
  end
end
