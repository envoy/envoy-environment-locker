ruby "2.6.2"
source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

gem 'rails', '~> 5.2.2'
gem 'puma', '~> 3.11'
gem 'bootsnap', '>= 1.1.0', require: false
gem "redis-rails", "~> 5.0.2"
gem "slack-notifier", "~> 2.3.2"

group :development, :test do
  gem 'pry-byebug', "~> 3.6.0"
  gem "rubocop", "~> 0.63.0", require: false
  gem 'dotenv-rails'
end

group :development do
  # Access an interactive console on exception pages or by calling 'console' anywhere in the code.
  gem 'web-console', '>= 3.3.0'
  gem 'listen', '>= 3.0.5', '< 3.2'
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
end

group :test do
  gem 'capybara', '>= 2.15'
  gem 'selenium-webdriver'
  gem 'chromedriver-helper'
  gem "rspec-rails", "~> 3.7.2"
  gem "fakeredis", "~> 0.7", require: "fakeredis/rspec"
  gem "stub_env", "~> 1.0"
  gem "timecop"
end

gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]
