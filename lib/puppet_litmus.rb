# frozen_string_literal: true

# Helper methods for testing puppet content
module PuppetLitmus; end

require 'bolt_spec/run'
require 'puppet_litmus/inventory_manipulation'
require 'puppet_litmus/puppet_helpers'
require 'puppet_litmus/rake_helper'
require 'puppet_litmus/spec_helper_acceptance'
require 'honeycomb-beeline'

# Helper methods for testing puppet content
module PuppetLitmus
  include BoltSpec::Run
  include PuppetLitmus::InventoryManipulation
  include PuppetLitmus::PuppetHelpers
  include PuppetLitmus::RakeHelper
  Honeycomb.configure do |config|
  end
  process_span = Honeycomb.start_span(name: 'Litmus Testing')
  if ENV['CI'] == 'true' && ENV['TRAVIS'] == 'true'
    process_span.add_field('module_name', ENV['TRAVIS_REPO_SLUG'])
    process_span.add_field('ci.provider', 'travis')
    process_span.add_field('ci.build_id', ENV['TRAVIS_BUILD_ID'])
    process_span.add_field('ci.build_url', ENV['TRAVIS_BUILD_WEB_URL'])
    process_span.add_field('ci.job_url', ENV['TRAVIS_JOB_WEB_URL'])
    process_span.add_field('ci.commit_message', ENV['TRAVIS_COMMIT_MESSAGE'])
    process_span.add_field('ci.sha', ENV['TRAVIS_PULL_REQUEST_SHA'])
  elsif ENV['CI'] == 'True' && ENV['APPVEYOR'] == 'True'
    process_span.add_field('module_name', ENV['APPVEYOR_PROJECT_SLUG'])
    process_span.add_field('ci.provider', 'appveyor')
    process_span.add_field('ci.build_id', ENV['APPVEYOR_BUILD_ID'])
    process_span.add_field('ci.build_url', "https://ci.appveyor.com/project/#{ENV['APPVEYOR_REPO_NAME']}/builds/#{ENV['APPVEYOR_BUILD_ID']}")
    process_span.add_field('ci.job_url', "https://ci.appveyor.com/project/#{ENV['APPVEYOR_REPO_NAME']}/build/job/#{ENV['APPVEYOR_JOB_ID']}")
    process_span.add_field('ci.commit_message', ENV['APPVEYOR_REPO_COMMIT_MESSAGE'])
    process_span.add_field('ci.sha', ENV['APPVEYOR_PULL_REQUEST_HEAD_COMMIT'])
  elsif ENV['GITHUB_ACTIONS'] == 'true'
    process_span.add_field('module_name', ENV['GITHUB_REPOSITORY'])
    process_span.add_field('ci.provider', 'github')
    process_span.add_field('ci.build_id', ENV['GITHUB_RUN_ID'])
    process_span.add_field('ci.build_url', "https://github.com/#{ENV['GITHUB_REPOSITORY']}/actions/runs/#{ENV['GITHUB_RUN_ID']}")
    process_span.add_field('ci.sha', ENV['GITHUB_SHA'])
  end
  at_exit do
    process_span.send
  end
end
