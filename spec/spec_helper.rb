# frozen_string_literal: true

require 'rspec'
require 'puppet_litmus'

# Unfortunately this needs to be included as this is
# how Litmus functions. We only include once here instead
# of including for every single spec file.
include PuppetLitmus # rubocop:disable Style/MixinUsage

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
