# frozen_string_literal: true

require 'rspec'
require 'puppet_litmus'

if ENV['COVERAGE'] == 'yes'
  require 'simplecov'

  SimpleCov.formatters = [
    SimpleCov::Formatter::HTMLFormatter,
  ]
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
