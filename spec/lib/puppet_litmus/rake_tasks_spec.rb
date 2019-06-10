# frozen_string_literal: true

require 'spec_helper'
require 'rake'

describe 'litmus rake tasks' do
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
end
