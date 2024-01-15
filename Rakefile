require 'bundler/gem_tasks'
require 'rubocop/rake_task'
require 'puppet_litmus/version'
require 'rspec/core/rake_task'
require 'yard'

RSpec::Core::RakeTask.new(:spec)
task :default => :spec

namespace :spec do
    desc 'Run RSpec code examples with coverage collection'
    task :coverage do
        ENV['COVERAGE'] = 'yes'
        Rake::Task['spec'].execute
    end
end

YARD::Rake::YardocTask.new do |t|
end
