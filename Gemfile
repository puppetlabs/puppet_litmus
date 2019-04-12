source 'https://rubygems.org'

gemspec

group :test do
  gem 'rake', '>= 10.0'
  gem 'rspec', '~> 3.0'
  gem 'rspec-collection_matchers', '~> 1.0'
  gem 'rspec-its', '~> 1.0'
  gem 'rubocop'
  gem 'rubocop-rspec'
end

group :development do
  # TODO: Use gem instead of git. Section mapping is merged into master, but not yet released
  gem 'github_changelog_generator', git: 'https://github.com/skywinder/github-changelog-generator.git', ref: '33f89614d47a4bca1a3ae02bdcc37edd0b012e86'
  gem 'pry'
end
