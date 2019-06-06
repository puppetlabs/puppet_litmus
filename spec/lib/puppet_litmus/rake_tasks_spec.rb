# frozen_string_literal: true

require 'spec_helper'
require 'rake'

describe 'litmus rake tasks' do
  before(:each) do
    load File.expand_path('../../../lib/puppet_litmus/rake_tasks.rb', __dir__)
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
end
