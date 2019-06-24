# frozen_string_literal: true

require 'pdk/module/build'
require 'spec_helper'
require 'rake'

describe 'litmus rake tasks' do
  class DummyClass
  end
  let(:dummy_class) do
    dummy_class = DummyClass.new
    dummy_class.extend(LitmusRakeHelper)
    dummy_class
  end

  before(:all) do # rubocop:disable RSpec/BeforeAfterAll
    load File.expand_path('../../../lib/puppet_litmus/rake_tasks.rb', __dir__)
    # the spec_prep task is stubbed, rather than load from another gem.
    Rake::Task.define_task(:spec_prep)
  end

  context 'with litmus:metadata task' do
    it 'happy path' do
      metadata = { 'name' => 'puppetlabs-postgresql',
                   'version' => '6.0.0',
                   'operatingsystem_support' =>
  [{ 'operatingsystem' => 'RedHat', 'operatingsystemrelease' => ['5'] },
   { 'operatingsystem' => 'Ubuntu', 'operatingsystemrelease' => ['14.04', '18.04'] }],
                   'template-ref' => 'heads/master-0-g7827fc2' }
      expect(File).to receive(:read).with(any_args).once
      expect(JSON).to receive(:parse).with(any_args).and_return(metadata)
      expect(STDOUT).to receive(:puts).with('redhat-5-x86_64')
      expect(STDOUT).to receive(:puts).with('ubuntu-1404-x86_64')
      expect(STDOUT).to receive(:puts).with('ubuntu-1804-x86_64')
      Rake::Task['litmus:metadata'].invoke
    end
  end

  context 'with litmus:provision_install task' do
    it 'happy path' do
      expect(Rake::Task['spec_prep']).to receive(:invoke).and_return('').once
      expect(Rake::Task['litmus:provision_list']).to receive(:invoke).with('default').once
      expect(Rake::Task['litmus:install_agent']).to receive(:invoke).with('puppet6').once
      expect(Rake::Task['litmus:install_module']).to receive(:invoke).once
      Rake::Task['litmus:provision_install'].invoke('default', 'puppet6')
    end
  end

  context 'with litmus:provision task' do
    it 'provisions' do
      results = [{ 'node' => 'localhost',
                   'target' => 'localhost',
                   'action' => 'task',
                   'object' => 'provision::docker',
                   'status' => 'success',
                   'result' => { 'status' => 'ok', 'node_name' => 'localhost:2222' } }]

      allow(File).to receive(:directory?).with(any_args).and_return(true)
      allow_any_instance_of(BoltSpec::Run).to receive(:run_task).with(any_args).and_return(results) # rubocop:disable RSpec/AnyInstance
      expect(STDOUT).to receive(:puts).with('localhost:2222, centos:7')
      Rake::Task['litmus:provision'].invoke('docker', 'centos:7')
    end
  end

  context 'with litmus:install_module task' do
    let(:result) { { 'node' => 'definitely.a.host', 'status' => 'success', 'result' => { 'exit_code' => 0, 'stdout' => nil, 'stderr' => nil } } }
    let(:module_tar) { '/tmp/themodule.tar.gz' }
    let(:module_list) { [{ 'node' => 'definitely.a.host', 'target' => 'definitely.a.host', 'action' => 'command', 'object' => 'puppet module list', 'status' => 'success', 'result' => { 'stdout' => "/etc/puppetlabs/code/environments/production/modules (no modules installed)\n/etc/puppetlabs/code/modules (no modules installed)\n/opt/puppetlabs/puppet/modules (no modules installed)\n", 'stderr' => '', 'exit_code' => 0 } }] } # rubocop:disable Metrics/LineLength

    it 'targeted host' do
      allow(File).to receive(:exist?).with(any_args).and_return(true)
      expect(YAML).to receive(:load_file).with(any_args).once
      allow_any_instance_of(PDK::Module::Build).to receive(:build).with(any_args).and_return(module_tar) # rubocop:disable RSpec/AnyInstance
      allow(Open3).to receive(:capture3).with('bundle exec bolt file upload /tmp/themodule.tar.gz /tmp/themodule.tar.gz --nodes definitely.a.host --inventoryfile inventory.yaml').and_return('')
      allow_any_instance_of(BoltSpec::Run).to receive(:run_command).with('puppet module install /tmp/themodule.tar.gz', # rubocop:disable RSpec/AnyInstance
                                                                         ['definitely.a.host'],
                                                                         config: nil,
                                                                         inventory: nil).and_return([result])
      Rake::Task['litmus:install_module'].invoke('definitely.a.host')
    end

    it 'targeted host with a puppetfile' do
      # rubocop:disable RSpec/AnyInstance
      allow(File).to receive(:exist?).with(any_args).and_return(true)
      expect(YAML).to receive(:load_file).with(any_args).once
      allow_any_instance_of(PDK::Module::Build).to receive(:build).with(any_args).and_return(module_tar)
      allow(Open3).to receive(:capture3).with('mkdir -p ~/.puppetlabs/bolt/').and_return('')
      allow(Open3).to receive(:capture3).with('mkdir -p ~/.puppetlabs/bolt/modules').and_return('')
      allow(Open3).to receive(:capture3).with('bolt puppetfile install').and_return('')
      allow(Open3).to receive(:capture3).with('cp puppetfile ~/.puppetlabs/bolt/Puppetfile').and_return('')
      allow_any_instance_of(BoltSpec::Run).to receive(:run_command).with('puppet module list',
                                                                         ['definitely.a.host'],
                                                                         config: nil,
                                                                         inventory: nil).and_return(module_list)

      allow(Open3).to receive(:capture3).with('bundle exec bolt file upload ~/.puppetlabs/bolt/modules '\
                                              '/etc/puppetlabs/code/environments/production/modules '\
                                              '--nodes definitely.a.host --inventoryfile inventory.yaml').and_return('')

      allow_any_instance_of(BoltSpec::Run).to receive(:run_command).with('mv /etc/puppetlabs/code/environments/production/modules/modules/* '\
                                                                         '/etc/puppetlabs/code/environments/production/modules',
                                                                         ['definitely.a.host'],
                                                                         config: nil,
                                                                         inventory: nil)
      allow_any_instance_of(BoltSpec::Run).to receive(:run_command).with('rmdir /etc/puppetlabs/code/environments/production/modules/modules', # rubocop:disable RSpec/AnyInstance
                                                                         ['definitely.a.host'],
                                                                         config: nil,
                                                                         inventory: nil)
      Rake::Task['litmus:install_module'].reenable
      Rake::Task['litmus:install_module'].invoke('definitely.a.host', 'puppetfile')
      # rubocop:enable RSpec/AnyInstance
    end
  end
end
