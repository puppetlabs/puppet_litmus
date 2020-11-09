source 'https://rubygems.org'

gemspec

group :test do
  gem 'rake', '>= 10.0'
  gem 'rspec', '~> 3.0'
  gem 'rspec-collection_matchers', '~> 1.0'
  gem 'rspec-its', '~> 1.0'
  gem 'rubocop', '~> 1.2'
  gem 'rubocop-rspec', '~> 1.38'
  gem 'codecov', '~> 0.1'
  gem 'simplecov', '~> 0.18'
end

group :development do
  gem 'github_changelog_generator'
  gem 'honeycomb-beeline'
  gem 'pry'
  gem 'yard'
end

# Evaluate Gemfile.local and ~/.gemfile if they exist
extra_gemfiles = [
  "#{__FILE__}.local",
  File.join(Dir.home, '.gemfile'),
]

extra_gemfiles.each do |gemfile|
  if File.file?(gemfile) && File.readable?(gemfile)
    eval(File.read(gemfile), binding)
  end
end
# vim: syntax=ruby
