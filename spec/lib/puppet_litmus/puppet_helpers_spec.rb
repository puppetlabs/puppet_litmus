# frozen_string_literal: true

require 'spec_helper'

RSpec.describe PuppetLitmus::PuppetHelpers do
  let(:inventory_hash) { { 'groups' => [{ 'name' => 'local', 'targets' => [{ 'uri' => 'some.host', 'config' => { 'transport' => 'local' }, 'facts' => facts_hash }] }] } }
  let(:localhost_inventory_hash) { { 'groups' => [{ 'name' => 'local', 'targets' => [{ 'uri' => 'litmus_localhost', 'config' => { 'transport' => 'local' }, 'facts' => facts_hash }] }] } }
  let(:facts_hash) { { 'provisioner' => 'docker', 'container_name' => 'litmusimage_debian_10-2222', 'platform' => 'litmusimage/debian:10' } }

  context 'with idempotent_apply' do
    let(:manifest) do
      "include '::doot'"
    end

    it 'calls all functions' do
      expect(self).to receive(:create_manifest_file).with(manifest).and_return('/bla.pp')
      expect(self).to receive(:apply_manifest).with(nil, catch_failures: true, manifest_file_location: '/bla.pp')
      expect(self).to receive(:apply_manifest).with(nil, catch_changes: true, manifest_file_location: '/bla.pp')
      idempotent_apply(manifest)
    end

    it 'passes options to apply_manifest' do
      expect(self).to receive(:create_manifest_file).with(manifest).and_return('/bla.pp')
      expect(self).to receive(:apply_manifest).with(nil, catch_failures: true, manifest_file_location: '/bla.pp', option: 'value')
      expect(self).to receive(:apply_manifest).with(nil, catch_changes: true, manifest_file_location: '/bla.pp', option: 'value')
      idempotent_apply(manifest, option: 'value')
    end
  end

  describe '.apply_manifest' do
    context 'when specifying a hiera config' do
      let(:manifest) { "include '::doot'" }
      let(:result) { ['value' => { 'exit_code' => 0, 'stdout' => nil, 'stderr' => nil }] }
      let :os do
        {
          family: 'redhat'
        }
      end
      let(:command) { "LC_ALL=en_US.UTF-8  puppet apply /bla.pp --trace --modulepath #{Dir.pwd}/spec/fixtures/modules --hiera_config='/hiera.yaml'" }

      it 'passes the --hiera_config flag if the :hiera_config opt is specified' do
        expect(File).to receive(:exist?).with('spec/fixtures/litmus_inventory.yaml').and_return(false)
        expect(self).to receive(:target_in_inventory?).and_return(true)
        expect(self).to receive(:target_in_inventory?).and_return(true)
        expect(self).to receive(:create_manifest_file).with(manifest).and_return('/bla.pp')
        expect(self).to receive(:run_command).with(command, 'litmus_localhost', config: nil, inventory: localhost_inventory_hash).and_return(result)
        apply_manifest(manifest, hiera_config: '/hiera.yaml')
      end
    end

    context 'when using detailed-exitcodes' do
      let(:manifest) { "include '::doot'" }
      let(:result) { ['value' => { 'exit_code' => 0, 'stdout' => nil, 'stderr' => nil }] }
      let(:command) { "LC_ALL=en_US.UTF-8  puppet apply /bla.pp --trace --modulepath #{Dir.pwd}/spec/fixtures/modules --detailed-exitcodes" }
      let :os do
        {
          family: 'redhat'
        }
      end

      it 'uses detailed-exitcodes with expect_failures' do
        expect(File).to receive(:exist?).with('spec/fixtures/litmus_inventory.yaml').and_return(false)
        expect(self).to receive(:target_in_inventory?).and_return(true)
        expect(self).to receive(:target_in_inventory?).and_return(true)
        expect(self).to receive(:create_manifest_file).with(manifest).and_return('/bla.pp')
        expect(self).to receive(:run_command).with(command, 'litmus_localhost', config: nil, inventory: localhost_inventory_hash).and_return(result)
        expect { apply_manifest(manifest, expect_failures: true) }.to raise_error(RuntimeError)
      end

      it 'uses detailed-exitcodes with catch_failures' do
        expect(File).to receive(:exist?).with('spec/fixtures/litmus_inventory.yaml').and_return(false)
        expect(self).to receive(:target_in_inventory?).and_return(true)
        expect(self).to receive(:target_in_inventory?).and_return(true)
        expect(self).to receive(:create_manifest_file).with(manifest).and_return('/bla.pp')
        expect(self).to receive(:run_command).with(command, 'litmus_localhost', config: nil, inventory: localhost_inventory_hash).and_return(result)
        apply_manifest(manifest, catch_failures: true)
      end

      it 'uses detailed-exitcodes with expect_changes' do
        expect(File).to receive(:exist?).with('spec/fixtures/litmus_inventory.yaml').and_return(false)
        expect(self).to receive(:target_in_inventory?).and_return(true)
        expect(self).to receive(:target_in_inventory?).and_return(true)
        expect(self).to receive(:create_manifest_file).with(manifest).and_return('/bla.pp')
        expect(self).to receive(:run_command).with(command, 'litmus_localhost', config: nil, inventory: localhost_inventory_hash).and_return(result)
        expect { apply_manifest(manifest, expect_changes: true) }.to raise_error(RuntimeError)
      end

      it 'uses detailed-exitcodes with catch_changes' do
        expect(File).to receive(:exist?).with('spec/fixtures/litmus_inventory.yaml').and_return(false)
        expect(self).to receive(:target_in_inventory?).and_return(true)
        expect(self).to receive(:target_in_inventory?).and_return(true)
        expect(self).to receive(:create_manifest_file).with(manifest).and_return('/bla.pp')
        expect(self).to receive(:run_command).with(command, 'litmus_localhost', config: nil, inventory: localhost_inventory_hash).and_return(result)
        apply_manifest(manifest, catch_changes: true)
      end

      it 'uses raises exception for multiple options' do
        expect { apply_manifest(manifest, catch_changes: true, expect_failures: true) }
          .to raise_error(RuntimeError, 'please specify only one of `catch_changes`, `expect_changes`, `catch_failures` or `expect_failures`')
      end
    end
  end

  describe '.run_shell' do
    let(:command_to_run) { "puts 'doot'" }
    let(:result) { ['value' => { 'exit_code' => 0, 'exit_status' => 0, 'stdout' => nil, 'stderr' => nil }] }

    it 'responds to run_shell' do
      expect(self).to respond_to(:run_shell).with(1..2).arguments
    end

    context 'when running against localhost and no inventory.yaml file' do
      it 'does run_shell against localhost without error' do
        stub_const('ENV', ENV.to_hash.merge('TARGET_HOST' => 'localhost'))
        expect(File).to receive(:exist?).with('spec/fixtures/litmus_inventory.yaml').and_return(false)
        expect(self).to receive(:target_in_inventory?).and_return(true)
        expect(self).to receive(:target_in_inventory?).and_return(true)
        expect(self).to receive(:run_command).with(command_to_run, 'litmus_localhost', config: nil, inventory: localhost_inventory_hash).and_return(result)
        expect { run_shell(command_to_run) }.not_to raise_error
      end
    end

    context 'when running against remote host' do
      it 'does run_shell against remote host without error' do
        stub_const('ENV', ENV.to_hash.merge('TARGET_HOST' => 'some.host'))
        expect(File).to receive(:exist?).with('spec/fixtures/litmus_inventory.yaml').and_return(true)
        expect(self).to receive(:inventory_hash_from_inventory_file).and_return(inventory_hash)
        expect(self).to receive(:target_in_inventory?).and_return(true)
        expect(self).to receive(:target_in_inventory?).and_return(true)
        expect(self).to receive(:run_command).with(command_to_run, 'some.host', config: nil, inventory: inventory_hash).and_return(result)
        expect { run_shell(command_to_run) }.not_to raise_error
      end
    end
  end

  describe '.bolt_upload_file' do
    let(:local) { '/tmp' }
    let(:remote) { '/remote_tmp' }
    # Ignore rubocop because these hashes are representative of output from an external method and editing them leads to test failures.
    # rubocop:disable Layout/SpaceAroundOperators, Layout/LineLength, Layout/SpaceAfterComma
    let(:result_success) { [{ 'target'=>'some.host','action'=>'upload','object'=>'C:\foo\bar.ps1','status'=>'success','value'=>{ '_output'=>'Uploaded \'C:\foo\bar.ps1\' to \'some.host:C:\bar\'' } }] }
    let(:result_failure) { [{ 'target'=>'some.host','action'=>nil,'object'=>nil,'status'=>'failure','value'=>{ '_error'=>{ 'kind'=>'puppetlabs.tasks/task_file_error','msg'=>'No such file or directory @ rb_sysopen - /nonexistant/file/path','details'=>{},'issue_code'=>'WRITE_ERROR' } } }] }
    # rubocop:enable, Layout/SpaceAroundOperators, Layout/LineLength, Layout/SpaceAfterComma

    it 'responds to run_shell' do
      expect(self).to respond_to(:bolt_upload_file).with(2..3).arguments
    end

    context 'when upload returns success' do
      it 'does upload_file against remote host without error' do
        stub_const('ENV', ENV.to_hash.merge('TARGET_HOST' => 'some.host'))
        expect(File).to receive(:exist?).with('spec/fixtures/litmus_inventory.yaml').and_return(true)
        expect(self).to receive(:inventory_hash_from_inventory_file).and_return(inventory_hash)
        expect(self).to receive(:target_in_inventory?).and_return(true)
        expect(self).to receive(:target_in_inventory?).and_return(true)
        expect(self).to receive(:upload_file).with(local, remote, 'some.host', options: {}, config: nil, inventory: inventory_hash).and_return(result_success)
        expect { bolt_upload_file(local, remote) }.not_to raise_error
      end

      it 'does upload_file against localhost without error' do
        stub_const('ENV', ENV.to_hash.merge('TARGET_HOST' => 'localhost'))
        expect(File).to receive(:exist?).with('spec/fixtures/litmus_inventory.yaml').and_return(false)
        expect(self).not_to receive(:inventory_hash_from_inventory_file)
        expect(self).to receive(:target_in_inventory?).and_return(true)
        expect(self).to receive(:target_in_inventory?).and_return(true)
        expect(self).to receive(:upload_file).with(local, remote, 'litmus_localhost', options: {}, config: nil, inventory: localhost_inventory_hash).and_return(result_success)
        expect { bolt_upload_file(local, remote) }.not_to raise_error
      end
    end

    context 'when upload returns failure' do
      it 'does upload_file gives runtime error for failure' do
        stub_const('ENV', ENV.to_hash.merge('TARGET_HOST' => 'some.host'))
        expect(File).to receive(:exist?).with('spec/fixtures/litmus_inventory.yaml').and_return(true)
        expect(self).to receive(:inventory_hash_from_inventory_file).and_return(inventory_hash)
        expect(self).to receive(:target_in_inventory?).and_return(true)
        expect(self).to receive(:target_in_inventory?).and_return(true)
        expect(self).to receive(:upload_file).with(local, remote, 'some.host', options: {}, config: nil, inventory: inventory_hash).and_return(result_failure)
        expect { bolt_upload_file(local, remote) }.to raise_error(RuntimeError, /upload file failed/)
      end

      it 'returns the exit code and error message when expecting failure' do
        stub_const('ENV', ENV.to_hash.merge('TARGET_HOST' => 'some.host'))
        expect(File).to receive(:exist?).with('spec/fixtures/litmus_inventory.yaml').and_return(true)
        expect(self).to receive(:inventory_hash_from_inventory_file).and_return(inventory_hash)
        expect(self).to receive(:target_in_inventory?).and_return(true)
        expect(self).to receive(:target_in_inventory?).and_return(true)
        expect(self).to receive(:upload_file).with(local, remote, 'some.host', options: {}, config: nil, inventory: inventory_hash).and_return(result_failure)
        method_result = bolt_upload_file(local, remote, expect_failures: true)
        expect(method_result.exit_code).to be(255)
        expect(method_result.stderr).to be('No such file or directory @ rb_sysopen - /nonexistant/file/path')
      end
    end
  end

  describe '.bolt_run_script' do
    let(:script) { '/tmp/script.sh' }
    let(:result) { ['value' => { 'exit_code' => 0, 'stdout' => nil, 'stderr' => nil }] }

    it 'responds to bolt_run_script' do
      expect(self).to respond_to(:bolt_run_script).with(1..2).arguments
    end

    context 'when running against localhost and no inventory.yaml file' do
      it 'does bolt_run_script against localhost without error' do
        stub_const('ENV', ENV.to_hash.merge('TARGET_HOST' => 'localhost'))
        expect(File).to receive(:exist?).with('spec/fixtures/litmus_inventory.yaml').and_return(false)
        expect(self).not_to receive(:inventory_hash_from_inventory_file)
        expect(self).to receive(:target_in_inventory?).and_return(true)
        expect(self).to receive(:target_in_inventory?).and_return(true)
        expect(self).to receive(:run_script).with(script, 'litmus_localhost', [], options: {}, config: nil, inventory: localhost_inventory_hash).and_return(result)
        expect { bolt_run_script(script) }.not_to raise_error
      end
    end

    context 'when running against remote host' do
      it 'does bolt_run_script against remote host without error' do
        stub_const('ENV', ENV.to_hash.merge('TARGET_HOST' => 'some.host'))
        expect(File).to receive(:exist?).with('spec/fixtures/litmus_inventory.yaml').and_return(true)
        expect(self).to receive(:inventory_hash_from_inventory_file).and_return(inventory_hash)
        expect(self).to receive(:target_in_inventory?).and_return(true)
        expect(self).to receive(:target_in_inventory?).and_return(true)
        expect(self).to receive(:run_script).with(script, 'some.host', [], options: {}, config: nil, inventory: inventory_hash).and_return(result)
        expect { bolt_run_script(script) }.not_to raise_error
      end
    end

    context 'when running with arguments' do
      it 'does bolt_run_script with arguments without error' do
        stub_const('ENV', ENV.to_hash.merge('TARGET_HOST' => 'localhost'))
        expect(File).to receive(:exist?).with('spec/fixtures/litmus_inventory.yaml').and_return(false)
        expect(self).not_to receive(:inventory_hash_from_inventory_file)
        expect(self).to receive(:target_in_inventory?).and_return(true)
        expect(self).to receive(:target_in_inventory?).and_return(true)
        expect(self).to receive(:run_script).with(script, 'litmus_localhost', ['doot'], options: {}, config: nil, inventory: localhost_inventory_hash).and_return(result)
        expect { bolt_run_script(script, arguments: ['doot']) }.not_to raise_error
      end
    end
  end

  describe '.run_bolt_task' do
    let(:task_name) { 'testtask' }
    let(:params) { { 'action' => 'install', 'name' => 'foo' } }
    let(:config_data) { { 'modulepath' => File.join(Dir.pwd, 'spec', 'fixtures', 'modules') } }
    # Ignore rubocop because these hashes are representative of output from an external method and editing them leads to test failures.
    # rubocop:disable Layout/SpaceBeforeBlockBraces
    let(:result_unstructured_task_success){ [{ 'target'=>'some.host','action'=>'task','object'=>'testtask::unstructured','status'=>'success','value'=>{ '_output'=>'SUCCESS!' } }] }
    let(:result_structured_task_success){ [{ 'target'=>'some.host','action'=>'task','object'=>'testtask::structured','status'=>'success','value'=>{ 'key1'=>'foo','key2'=>'bar' } }] }
    let(:result_failure) { [{ 'target'=>'some.host','action'=>'task','object'=>'testtask::unstructured','status'=>'failure','value'=>{ '_error'=>{ 'msg'=>'FAILURE!','kind'=>'puppetlabs.tasks/task-error','details'=>{ 'exitcode'=>123 } } } }] }
    # rubocop:enable Layout/SpaceBeforeBlockBraces, Layout/SpaceAroundOperators, Layout/LineLength, Layout/SpaceAfterComma

    it 'responds to bolt_run_task' do
      expect(self).to respond_to(:run_bolt_task).with(2..3).arguments
    end

    context 'when bolt returns success' do
      it 'does bolt_task_run gives no runtime error for success' do
        stub_const('ENV', ENV.to_hash.merge('TARGET_HOST' => 'some.host'))
        expect(File).to receive(:exist?).with('spec/fixtures/litmus_inventory.yaml').and_return(true)
        expect(self).to receive(:inventory_hash_from_inventory_file).and_return(inventory_hash)
        expect(self).to receive(:target_in_inventory?).and_return(true)
        expect(self).to receive(:target_in_inventory?).and_return(true)
        expect(self).to receive(:run_task).with(task_name, 'some.host', params, config: config_data, inventory: inventory_hash).and_return(result_unstructured_task_success)
        expect { run_bolt_task(task_name, params, opts: {}) }.not_to raise_error
      end

      it 'does bolt_task_run gives no runtime error for success, for a named inventory file' do
        stub_const('ENV', ENV.to_hash.merge('TARGET_HOST' => 'some.host'))
        expect(File).to receive(:exist?).with('jim.yaml').and_return(true)
        expect(self).to receive(:inventory_hash_from_inventory_file).and_return(inventory_hash)
        expect(self).to receive(:target_in_inventory?).and_return(true)
        expect(self).to receive(:target_in_inventory?).and_return(true)
        expect(self).to receive(:run_task).with(task_name, 'some.host', params, config: config_data, inventory: inventory_hash).and_return(result_unstructured_task_success)
        expect { run_bolt_task(task_name, params, inventory_file: 'jim.yaml') }.not_to raise_error
      end

      it 'returns stdout for unstructured-data tasks' do
        stub_const('ENV', ENV.to_hash.merge('TARGET_HOST' => 'some.host'))
        expect(File).to receive(:exist?).with('spec/fixtures/litmus_inventory.yaml').and_return(true)
        expect(self).to receive(:inventory_hash_from_inventory_file).and_return(inventory_hash)
        expect(self).to receive(:target_in_inventory?).and_return(true)
        expect(self).to receive(:target_in_inventory?).and_return(true)
        expect(self).to receive(:run_task).with(task_name, 'some.host', params, config: config_data, inventory: inventory_hash).and_return(result_unstructured_task_success)
        method_result = run_bolt_task(task_name, params, opts: {})
        expect(method_result.stdout).to eq('SUCCESS!')
      end

      it 'returns structured output for structured-data tasks' do
        stub_const('ENV', ENV.to_hash.merge('TARGET_HOST' => 'some.host'))
        expect(File).to receive(:exist?).with('spec/fixtures/litmus_inventory.yaml').and_return(true)
        expect(self).to receive(:inventory_hash_from_inventory_file).and_return(inventory_hash)
        expect(self).to receive(:target_in_inventory?).and_return(true)
        expect(self).to receive(:target_in_inventory?).and_return(true)
        expect(self).to receive(:run_task).with(task_name, 'some.host', params, config: config_data, inventory: inventory_hash).and_return(result_structured_task_success)
        method_result = run_bolt_task(task_name, params, opts: {})
        expect(method_result.stdout).to eq('{"key1"=>"foo", "key2"=>"bar"}')
        expect(method_result.result['key1']).to eq('foo')
        expect(method_result.result['key2']).to eq('bar')
      end
    end

    context 'when bolt returns failure' do
      it 'does bolt_task_run gives runtime error for failure' do
        stub_const('ENV', ENV.to_hash.merge('TARGET_HOST' => 'some.host'))
        expect(File).to receive(:exist?).with('spec/fixtures/litmus_inventory.yaml').and_return(true)
        expect(self).to receive(:inventory_hash_from_inventory_file).and_return(inventory_hash)
        expect(self).to receive(:target_in_inventory?).and_return(true)
        expect(self).to receive(:target_in_inventory?).and_return(true)
        expect(self).to receive(:run_task).with(task_name, 'some.host', params, config: config_data, inventory: inventory_hash).and_return(result_failure)
        expect { run_bolt_task(task_name, params, opts: {}) }.to raise_error(RuntimeError, /task failed/)
      end

      it 'returns the exit code and error message when expecting failure' do
        stub_const('ENV', ENV.to_hash.merge('TARGET_HOST' => 'some.host'))
        expect(File).to receive(:exist?).with('spec/fixtures/litmus_inventory.yaml').and_return(true)
        expect(self).to receive(:inventory_hash_from_inventory_file).and_return(inventory_hash)
        expect(self).to receive(:target_in_inventory?).and_return(true)
        expect(self).to receive(:target_in_inventory?).and_return(true)
        expect(self).to receive(:run_task).with(task_name, 'some.host', params, config: config_data, inventory: inventory_hash).and_return(result_failure)
        method_result = run_bolt_task(task_name, params, expect_failures: true)
        expect(method_result.exit_code).to be(123)
        expect(method_result.stderr).to be('FAILURE!')
      end
    end
  end

  describe '.write_file' do
    let(:content) { 'foo' }
    let(:destination) { '/tmp/foo' }
    let(:owner) { 'foo:foo' }
    let(:local_path) { '/tmp/local_foo' }

    before do
      allow_any_instance_of(File).to receive(:path).and_return(local_path)
    end

    it 'responds to write_file' do
      expect(self).to respond_to(:write_file).with(2).arguments
    end

    context 'without setting owner' do
      it 'call upload file with the correct params' do
        stub_const('ENV', ENV.to_hash.merge('TARGET_HOST' => 'some.host'))
        expect(self).to receive(:inventory_hash_from_inventory_file).and_return(inventory_hash)

        expected_result = [{ 'status' => 'success' }]
        expect(self).to receive(:upload_file).with(local_path, destination, 'some.host', options: {}, config: nil, inventory: inventory_hash).and_return(expected_result)

        result = write_file(content, destination)
        expect(result).to be true
      end
    end

    context 'when upload encounters an error' do
      it 'call upload file with the correct params' do
        stub_const('ENV', ENV.to_hash.merge('TARGET_HOST' => 'some.host'))
        expect(self).to receive(:inventory_hash_from_inventory_file).and_return(inventory_hash)

        expected_result = [{ 'status' => 'failure', 'value' => 'foo error' }]
        expect(self).to receive(:upload_file).with(local_path, destination, 'some.host', options: {}, config: nil, inventory: inventory_hash).and_return(expected_result)

        expect { write_file(content, destination) }.to raise_error 'foo error'
      end
    end
  end
end
