# frozen_string_literal: true

source 'https://rubygems.org'
git_source(:github) {|repo| "https://github.com/#{repo}.git" }

ruby '3.0.2'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails', branch: 'main'
gem 'rails', '~> 6.1.4'

# Use postgresql as the database for Active Record
gem 'pg', '~> 1.2'

# Use Puma as the app server
gem 'puma', '~> 5.3.2'

# Use google-id-token gem to verify tokens sent from Google OAuth
gem 'google-id-token', '~> 1.4.2'

# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', '>= 1.7.6', require: false

# Use Rack CORS for handling Cross-Origin Resource Sharing (CORS), making cross-origin AJAX possible
gem 'rack-cors', '~> 1.1.1'

# Use configatron for app config
gem 'configatron', '~> 4.5.1'

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', '~> 11.1', platforms: %i[mri mingw x64_mingw]

  # Use RSpec for unit and integration testing
  gem 'rspec-rails', '~> 5.0.1'

  # Use Timecop to freeze time in tests (for testing timestamps, etc.)
  gem 'timecop', '~> 0.9.4'

  # Use DatabaseCleaner to clear the database between specs
  gem 'database_cleaner-active_record', '~> 2.0.1'

  # Use FactoryBot to create models for tests
  gem 'factory_bot_rails', '~> 6.2.0'

  # Use Rubocop to enforce style guide
  gem 'rubocop-rails', '~> 2.11.3', require: false

  # Use Rubocop to enforce RSpec styles
  gem 'rubocop-rspec', '~> 2.4.0', require: false

  # Use Rubocop to enforce performance standards
  gem 'rubocop-performance', '~> 1.11.4', require: false
end

group :development do
  # Use listen to hot-reload app code
  gem 'listen', '~> 3.6'

  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring', '~> 2.1'
end
