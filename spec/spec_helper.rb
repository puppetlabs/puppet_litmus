# frozen_string_literal: true

require 'rspec'
require 'open3'
require 'ostruct'

if ENV['COVERAGE'] == 'yes'
  begin
    require 'simplecov'
    require 'simplecov-console'
    SimpleCov.formatters = [
      SimpleCov::Formatter::HTMLFormatter,
      SimpleCov::Formatter::Console
    ]

    SimpleCov.start do
      track_files 'lib/**/*.rb'

      add_filter '/spec'
      add_filter 'lib/puppet_litmus/version.rb'
      # do not track vendored files
      add_filter '/vendor'
      add_filter '/.vendor'
    end
  rescue LoadError
    raise 'Add the simplecov & simplecov-console gems to Gemfile to enable this task'
  end
end

def run_matrix_from_metadata_v2(options = {})
  command = 'bundle exec ./exe/matrix_from_metadata_v2'
  command += " --exclude-platforms '#{options['--exclude-platforms']}'" unless options['--exclude-platforms'].nil?
  result = Open3.capture3({ 'TEST_MATRIX_FROM_METADATA' => 'spec/exe/fake_metadata.json' }, command)
  OpenStruct.new(
    stdout: result[0],
    stderr: result[1],
    status_code: result[2]
  )
end

def run_matrix_from_metadata_v3(options = [])
  command = %w[bundle exec ./exe/matrix_from_metadata_v3]
  unless options.include? '--metadata'
    options << '--metadata'
    options << File.join(File.dirname(__FILE__), 'exe', 'fake_metadata.json')
  end
  command += options
  result = Open3.capture3(*command)
  OpenStruct.new(
    stdout: result[0],
    stderr: result[1],
    status_code: result[2]
  )
end

# This is basically how `configure!` sets up RSpec in tests.
require 'puppet_litmus'
RSpec.configure do |config|
  config.include PuppetLitmus
  config.extend PuppetLitmus
end
