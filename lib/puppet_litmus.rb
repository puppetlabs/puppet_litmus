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
    # config.debug = true
  end
  process_span = Honeycomb.start_span(name: 'Litmus Testing')
  if ENV['CI'] == 'true' && ENV['TRAVIS'] == 'true'
    process_span.add_field('module_name', ENV['TRAVIS_REPO_SLUG'])
    process_span.add_field('travis_build_id', ENV['TRAVIS_BUILD_ID'])
    process_span.add_field('travis_build_web_url', ENV['TRAVIS_BUILD_WEB_URL'])
    process_span.add_field('travis_commit_message', ENV['TRAVIS_COMMIT_MESSAGE'])
    process_span.add_field('travis_pull_request_sha', ENV['TRAVIS_PULL_REQUEST_SHA'])
  elsif ENV['CI'] == 'True' && ENV['APPVEYOR'] == 'True'
    process_span.add_field('module_name', ENV['APPVEYOR_PROJECT_SLUG'])
    process_span.add_field('appveyor_build_id', ENV['APPVEYOR_BUILD_ID'])
    process_span.add_field('appveyor_url', "https://ci.appveyor.com/project/#{ENV['APPVEYOR_REPO_NAME']}/builds/#{ENV['APPVEYOR_BUILD_ID']}")
    process_span.add_field('appveyor_repo_commit_message', ENV['APPVEYOR_REPO_COMMIT_MESSAGE'])
    process_span.add_field('appveyor_pull_request_head_commit', ENV['APPVEYOR_PULL_REQUEST_HEAD_COMMIT'])
  end
  at_exit do
    process_span.send
  end
end
