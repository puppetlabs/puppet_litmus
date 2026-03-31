source 'https://rubygems.org'

source 'https://rubygems-puppetcore.puppet.com' do
  gem 'bolt', '>= 5.0', '< 6.0'
end

gemspec

group :test do
  gem 'rake'
  gem 'rspec', '~> 3.1'
  gem 'rspec-collection_matchers', '~> 1.0'
  gem 'rspec-its', '~> 1.0'

  gem 'rubocop', '~> 1.64.0'
  gem 'rubocop-rspec', '~> 3.0'
  gem 'rubocop-performance', '~> 1.16'

  gem 'simplecov'
  gem 'simplecov-console'
end

group :development do
  gem 'pry'
  gem 'yard'
end
