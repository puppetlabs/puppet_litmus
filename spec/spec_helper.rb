# frozen_string_literal: true

require 'rspec'
require 'open3'
require 'ostruct'

if ENV['COVERAGE'] == 'yes'
  require 'simplecov'

  if ENV['CI'] == 'true'
    require 'codecov'
    SimpleCov.formatter = SimpleCov::Formatter::Codecov
  else
    SimpleCov.formatters = [
      SimpleCov::Formatter::HTMLFormatter,
    ]
  end
  SimpleCov.start do
    track_files 'lib/**/*.rb'

    add_filter '/spec'

    # do not track vendored files
    add_filter '/vendor'
    add_filter '/.vendor'

    # do not track gitignored files
    # this adds about 4 seconds to the coverage check
    # this could definitely be optimized
    add_filter do |f|
      # system returns true if exit status is 0, which with git-check-ignore means file is ignored
      system("git check-ignore --quiet #{f.filename}")
    end
  end
end

def run_matrix_from_metadata_v2(options = {})
  command = 'bundle exec ./exe/matrix_from_metadata_v2'
  command += " --exclude-platforms '#{options['--exclude-platforms']}'" unless options['--exclude-platforms'].nil?
  result = Open3.capture3({ 'TEST_MATRIX_FROM_METADATA' => 'spec/exe/fake_metadata.json' }, command)
  OpenStruct.new(
    stdout: result[0],
    stderr: result[1],
    status_code: result[2],
  )
end

# This is basically how `configure!` sets up RSpec in tests.
require 'puppet_litmus'
RSpec.configure do |config|
  config.include PuppetLitmus
  config.extend PuppetLitmus
end
