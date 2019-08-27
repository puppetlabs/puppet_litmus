# frozen_string_literal: true

require 'spec_helper'

RSpec.describe PuppetLitmus::Serverspec do
  let(:dummy_class) do
    dummy = Class.new
    dummy.extend(described_class)
    dummy
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

  describe '.apply_manifest' do
    context 'when specifying a hiera config' do
      let(:manifest) { "include '::doot'" }
      let(:result) { ['result' => { 'exit_code' => 0, 'stdout' => nil, 'stderr' => nil }] }
      let(:command) { " puppet apply /bla.pp --modulepath #{Dir.pwd}/spec/fixtures/modules --hiera_config='/hiera.yaml'" }

      it 'passes the --hiera_config flag if the :hiera_config opt is specified' do
        expect(dummy_class).to receive(:create_manifest_file).with(manifest).and_return('/bla.pp')
        expect(dummy_class).to receive(:run_command).with(command, nil, config: nil, inventory: nil).and_return(result)
        dummy_class.apply_manifest(manifest, hiera_config: '/hiera.yaml')
      end
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
        stub_const('ENV', ENV.to_hash.merge('TARGET_HOST' => 'localhost'))
        expect(dummy_class).to receive(:run_command).with(command_to_run, 'localhost', config: nil, inventory: nil).and_return(result)
        expect { dummy_class.run_shell(command_to_run) }.not_to raise_error
      end
    end

    context 'when running against remote host' do
      it 'does run_shell against remote host without error' do
        stub_const('ENV', ENV.to_hash.merge('TARGET_HOST' => 'some.host'))
        expect(dummy_class).to receive(:inventory_hash_from_inventory_file).and_return(inventory_hash)
        expect(dummy_class).to receive(:run_command).with(command_to_run, 'some.host', config: nil, inventory: inventory_hash).and_return(result)
        expect { dummy_class.run_shell(command_to_run) }.not_to raise_error
      end
    end
  end

  describe '.bolt_upload_file' do
    let(:local) { '/tmp' }
    let(:remote) { '/remote_tmp' }
    # Ignore rubocop because these hashes are representative of output from an external method and editing them leads to test failures.
    # rubocop:disable SpaceInsideHashLiteralBraces, SpaceInsideBlockBraces, SpaceAroundOperators, LineLength, SpaceAfterComma
    let(:result_success) {[{'node'=>'some.host','target'=>'some.host','action'=>'upload','object'=>'C:\foo\bar.ps1','status'=>'success','result'=>{'_output'=>'Uploaded \'C:\foo\bar.ps1\' to \'some.host:C:\bar\''}}]}
    let(:result_failure) {[{'node'=>'some.host','target'=>'some.host','action'=>nil,'object'=>nil,'status'=>'failure','result'=>{'_error'=>{'kind'=>'puppetlabs.tasks/task_file_error','msg'=>'No such file or directory @ rb_sysopen - /nonexistant/file/path','details'=>{},'issue_code'=>'WRITE_ERROR'}}}]}
    # rubocop:enable SpaceInsideHashLiteralBraces, SpaceInsideBlockBraces, SpaceAroundOperators, LineLength, SpaceAfterComma
    let(:inventory_hash) { Hash.new(0) }

    it 'responds to run_shell' do
      expect(dummy_class).to respond_to(:bolt_upload_file).with(2..3).arguments
    end

    context 'when upload returns success' do
      it 'does upload_file against remote host without error' do
        stub_const('ENV', ENV.to_hash.merge('TARGET_HOST' => 'some.host'))
        expect(dummy_class).to receive(:inventory_hash_from_inventory_file).and_return(inventory_hash)
        expect(dummy_class).to receive(:upload_file).with(local, remote, 'some.host', options: {}, config: nil, inventory: inventory_hash).and_return(result_success)
        expect { dummy_class.bolt_upload_file(local, remote) }.not_to raise_error
      end
      it 'does upload_file against localhost without error' do
        stub_const('ENV', ENV.to_hash.merge('TARGET_HOST' => 'localhost'))
        expect(dummy_class).not_to receive(:inventory_hash_from_inventory_file)
        expect(dummy_class).to receive(:upload_file).with(local, remote, 'localhost', options: {}, config: nil, inventory: nil).and_return(result_success)
        expect { dummy_class.bolt_upload_file(local, remote) }.not_to raise_error
      end
    end

    context 'when upload returns failure' do
      it 'does upload_file gives runtime error for failure' do
        stub_const('ENV', ENV.to_hash.merge('TARGET_HOST' => 'some.host'))
        expect(dummy_class).to receive(:inventory_hash_from_inventory_file).and_return(inventory_hash)
        expect(dummy_class).to receive(:upload_file).with(local, remote, 'some.host', options: {}, config: nil, inventory: inventory_hash).and_return(result_failure)
        expect { dummy_class.bolt_upload_file(local, remote) }.to raise_error(RuntimeError, %r{upload file failed})
      end
      it 'returns the exit code and error message when expecting failure' do
        stub_const('ENV', ENV.to_hash.merge('TARGET_HOST' => 'some.host'))
        expect(dummy_class).to receive(:inventory_hash_from_inventory_file).and_return(inventory_hash)
        expect(dummy_class).to receive(:upload_file).with(local, remote, 'some.host', options: {}, config: nil, inventory: inventory_hash).and_return(result_failure)
        method_result = dummy_class.bolt_upload_file(local, remote, expect_failures: true)
        expect(method_result.exit_code).to be(255)
        expect(method_result.stderr).to be('No such file or directory @ rb_sysopen - /nonexistant/file/path')
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
        stub_const('ENV', ENV.to_hash.merge('TARGET_HOST' => 'localhost'))
        expect(dummy_class).not_to receive(:inventory_hash_from_inventory_file)
        expect(dummy_class).to receive(:run_script).with(script, 'localhost', [], options: {}, config: nil, inventory: nil).and_return(result)
        expect { dummy_class.bolt_run_script(script) }.not_to raise_error
      end
    end

    context 'when running against remote host' do
      it 'does bolt_run_script against remote host without error' do
        stub_const('ENV', ENV.to_hash.merge('TARGET_HOST' => 'some.host'))
        expect(dummy_class).to receive(:inventory_hash_from_inventory_file)
        expect(dummy_class).to receive(:run_script).with(script, 'some.host', [], options: {}, config: nil, inventory: nil).and_return(result)
        expect { dummy_class.bolt_run_script(script) }.not_to raise_error
      end
    end

    context 'when running with arguments' do
      it 'does bolt_run_script with arguments without error' do
        stub_const('ENV', ENV.to_hash.merge('TARGET_HOST' => 'localhost'))
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
    # Ignore rubocop because these hashes are representative of output from an external method and editing them leads to test failures.
    # rubocop:disable SpaceInsideHashLiteralBraces, SpaceBeforeBlockBraces, SpaceInsideBlockBraces, SpaceAroundOperators, LineLength, SpaceAfterComma
    let(:result_unstructured_task_success){ [{'node'=>'some.host','target'=>'some.host','action'=>'task','object'=>'testtask::unstructured','status'=>'success','result'=>{'_output'=>'SUCCESS!'}}]}
    let(:result_structured_task_success){ [{'node'=>'some.host','target'=>'some.host','action'=>'task','object'=>'testtask::structured','status'=>'success','result'=>{'key1'=>'foo','key2'=>'bar'}}]}
    let(:result_failure) {[{'node'=>'some.host','target'=>'some.host','action'=>'task','object'=>'testtask::unstructured','status'=>'failure','result'=>{'_error'=>{'msg'=>'FAILURE!','kind'=>'puppetlabs.tasks/task-error','details'=>{'exitcode'=>123}}}}]}
    # rubocop:enable SpaceInsideHashLiteralBraces, SpaceBeforeBlockBraces, SpaceInsideBlockBraces, SpaceAroundOperators, LineLength, SpaceAfterComma
    let(:inventory_hash) { Hash.new(0) }

    it 'responds to bolt_run_task' do
      expect(dummy_class).to respond_to(:run_bolt_task).with(2..3).arguments
    end

    context 'when bolt returns success' do
      it 'does bolt_task_run gives no runtime error for success' do
        stub_const('ENV', ENV.to_hash.merge('TARGET_HOST' => 'some.host'))
        expect(dummy_class).to receive(:inventory_hash_from_inventory_file).and_return(inventory_hash)
        expect(dummy_class).to receive(:run_task).with(task_name, 'some.host', params, config: config_data, inventory: inventory_hash).and_return(result_unstructured_task_success)
        expect { dummy_class.run_bolt_task(task_name, params, opts: {}) }.not_to raise_error
      end
      it 'returns stdout for unstructured-data tasks' do
        stub_const('ENV', ENV.to_hash.merge('TARGET_HOST' => 'some.host'))
        expect(dummy_class).to receive(:inventory_hash_from_inventory_file).and_return(inventory_hash)
        expect(dummy_class).to receive(:run_task).with(task_name, 'some.host', params, config: config_data, inventory: inventory_hash).and_return(result_unstructured_task_success)
        method_result = dummy_class.run_bolt_task(task_name, params, opts: {})
        expect(method_result.stdout).to eq('SUCCESS!')
      end
      it 'returns structured output for structured-data tasks' do
        stub_const('ENV', ENV.to_hash.merge('TARGET_HOST' => 'some.host'))
        expect(dummy_class).to receive(:inventory_hash_from_inventory_file).and_return(inventory_hash)
        expect(dummy_class).to receive(:run_task).with(task_name, 'some.host', params, config: config_data, inventory: inventory_hash).and_return(result_structured_task_success)
        method_result = dummy_class.run_bolt_task(task_name, params, opts: {})
        expect(method_result.stdout).to eq('{"key1"=>"foo", "key2"=>"bar"}')
        expect(method_result.result['key1']).to eq('foo')
        expect(method_result.result['key2']).to eq('bar')
      end
    end

    context 'when bolt returns failure' do
      it 'does bolt_task_run gives runtime error for failure' do
        stub_const('ENV', ENV.to_hash.merge('TARGET_HOST' => 'some.host'))
        expect(dummy_class).to receive(:inventory_hash_from_inventory_file).and_return(inventory_hash)
        expect(dummy_class).to receive(:run_task).with(task_name, 'some.host', params, config: config_data, inventory: inventory_hash).and_return(result_failure)
        expect { dummy_class.run_bolt_task(task_name, params, opts: {}) }.to raise_error(RuntimeError, %r{task failed})
      end
      it 'returns the exit code and error message when expecting failure' do
        stub_const('ENV', ENV.to_hash.merge('TARGET_HOST' => 'some.host'))
        expect(dummy_class).to receive(:inventory_hash_from_inventory_file).and_return(inventory_hash)
        expect(dummy_class).to receive(:run_task).with(task_name, 'some.host', params, config: config_data, inventory: inventory_hash).and_return(result_failure)
        method_result = dummy_class.run_bolt_task(task_name, params, expect_failures: true)
        expect(method_result.exit_code).to be(123)
        expect(method_result.stderr).to be('FAILURE!')
      end
    end
  end
end
