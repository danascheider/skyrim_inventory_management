# frozen_string_literal: true

source 'https://rubygems.org'
git_source(:github) {|repo| "https://github.com/#{repo}.git" }

ruby '3.2.2'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails', branch: 'main'
gem 'rails', '~> 7.1.2'

# Use postgresql as the database for Active Record
gem 'pg', '~> 1.5'

# Use Puma as the app server
gem 'puma', '~> 6.4.2'

# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', '~> 1.17', require: false

# Use Rack CORS for handling Cross-Origin Resource Sharing (CORS), making cross-origin AJAX possible
gem 'rack-cors', '~> 2.0.1'

# Use Faraday to validate Google auth access tokens
gem 'faraday', '~> 2.8.1'

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', '~> 11.1', platforms: %i[mri mingw x64_mingw]

  # Use RSpec for unit and integration testing
  gem 'rspec-rails', '~> 6.1'

  # Use Timecop to freeze time in tests (for testing timestamps, etc.)
  gem 'timecop', '~> 0.9.8'

  # Use DatabaseCleaner to clear the database between specs
  gem 'database_cleaner-active_record', '~> 2.1'

  # Use FactoryBot to create models for tests
  gem 'factory_bot_rails', '~> 6.4.3'

  # Use Rubocop to enforce style guide
  gem 'rubocop-rails', '~> 2.23', require: false

  # Use Rubocop to enforce RSpec styles
  gem 'rubocop-rspec', '~> 2.26', require: false

  # Use Rubocop to enforce performance standards
  gem 'rubocop-performance', '~> 1.20', require: false

  # Use Rubocop to lint factories
  gem 'rubocop-factory_bot', '~> 2.24', require: false

  # Use WebMock to mock HTTP requests, mainly for auth purposes
  gem 'webmock', '~> 3.19'
end

group :development do
  # Use listen to hot-reload app code
  gem 'listen', '~> 3.7'

  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring', '~> 4.1'

  # Load environment variables in dev
  gem 'dotenv', '~> 2.8'
end
