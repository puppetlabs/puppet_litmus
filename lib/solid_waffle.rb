# frozen_string_literal: true

require 'pry'
require 'bolt_spec/run'

# Helper methods for testing puppet content
module SolidWaffle
  include BoltSpec::Run
  def apply_manifest(manifest, _fuckit)
    config_data = {
      'ssh' =>  { 'host-key-check' => false },
      'winrm' => { 'ssl' => false },
    }
    host = ENV['HOSTY']
    result = run_command("/opt/puppetlabs/puppet/bin/puppet apply -e '#{manifest}'", host, config: config_data)
    result
  end

  def akimbo
    puts 'akimbo'
  end
end
