# frozen_string_literal: true

source 'https://rubygems.org'
git_source(:github) {|repo| "https://github.com/#{repo}.git" }

ruby '3.2.2'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails', branch: 'main'
gem 'rails', '~> 7.0.3'

# Use postgresql as the database for Active Record
gem 'pg', '~> 1.3'

# Use Puma as the app server
gem 'puma', '~> 5.6.4'

# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', '>= 1.12.0', require: false

# Use Rack CORS for handling Cross-Origin Resource Sharing (CORS), making cross-origin AJAX possible
gem 'rack-cors', '~> 1.1.1'

# Use configatron for app config
gem 'configatron', '~> 4.5.1'

# Use Faraday to validate Google auth access tokens
gem 'faraday', '~> 2.7.4'

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', '~> 11.1', platforms: %i[mri mingw x64_mingw]

  # Use RSpec for unit and integration testing
  gem 'rspec-rails', '~> 5.1'

  # Use Timecop to freeze time in tests (for testing timestamps, etc.)
  gem 'timecop', '~> 0.9.5'

  # Use DatabaseCleaner to clear the database between specs
  gem 'database_cleaner-active_record', '~> 2.0.1'

  # Use FactoryBot to create models for tests
  gem 'factory_bot_rails', '~> 6.2.0'

  # Use Rubocop to enforce style guide
  gem 'rubocop-rails', '~> 2.14', require: false

  # Use Rubocop to enforce RSpec styles
  gem 'rubocop-rspec', '~> 2.11', require: false

  # Use Rubocop to enforce performance standards
  gem 'rubocop-performance', '~> 1.14', require: false

  # Use WebMock to mock HTTP requests, mainly for auth purposes
  gem 'webmock', '~> 3.18.1'
end

group :development do
  # Use listen to hot-reload app code
  gem 'listen', '~> 3.7'

  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring', '~> 4.0'

  # Load environment variables in dev
  gem 'dotenv', '~> 2.8'
end
