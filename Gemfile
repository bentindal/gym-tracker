# frozen_string_literal: true

source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '3.2.1'

# Bundle edge Rails instead: gem "rails", github: "rails/rails", branch: "main"
gem 'rails', '7.0.4.3'

# The original asset pipeline for Rails [https://github.com/rails/sprockets-rails]
gem 'sprockets-rails', '3.4.2'

# Optimized SASS processing for Rails
gem 'sassc', '2.1.0'
gem 'sassc-rails', '2.1.0'

# Use Font Awesome with SASS support
gem 'font-awesome-rails', '4.7.0.8'

# Use sqlite3 as the database for Active Record
gem 'sqlite3', '1.6.2'

# Using devise for authentication
gem 'devise', '4.8.1'

# Prefer use of haml over erb
gem 'haml', '6.0.7'
gem 'haml-rails', '2.1.0'

# Use the Puma web server [https://github.com/puma/puma]
gem 'puma', '5.6.7'

# jquery for confirmations
gem 'jquery-rails', '4.5.1'

# Use JavaScript with ESM import maps [https://github.com/rails/importmap-rails]
gem 'importmap-rails', '1.1.5'

# Hotwire's SPA-like page accelerator [https://turbo.hotwired.dev]
gem 'turbo-rails', '1.4.0'

# Whenever gem for cron jobs
gem 'whenever'

# Hotwire's modest JavaScript framework [https://stimulus.hotwired.dev]
gem 'stimulus-rails', '1.2.1'

# Build JSON APIs with ease [https://github.com/rails/jbuilder]
gem 'jbuilder', '2.11.5'

# Sitemap generator
gem 'sitemap_generator', '6.3.0'

# Chartkick
gem 'chartkick', '5.0.2'

# JavaScript compression
gem 'terser', '~> 1.1'

# Uglifier for js minification
gem 'uglifier', '4.2.0'

gem 'execjs', '2.8.1'

# Add logger gem
gem 'logger'

# OpenAI API client
gem 'ruby-openai'

gem 'dotenv-rails'

# Use Redis adapter to run Action Cable in production
# gem "redis", "~> 4.0"

# Use Kredis to get higher-level data types in Redis [https://github.com/rails/kredis]
# gem "kredis"

# Use Active Model has_secure_password [https://guides.rubyonrails.org/active_model_basics.html#securepassword]
# gem "bcrypt", "~> 3.1.7"

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: %i[mingw mswin x64_mingw jruby]

# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', '1.16.0'

gem 'simple_form', '5.2.0'

# Handle native extensions
gem 'json', '~> 2.6.3'
gem 'msgpack', '~> 1.6.0'

group :development, :test do
  # See https://guides.rubyonrails.org/debugging_rails_applications.html#debugging-with-the-debug-gem
  gem 'debug', '1.7.2', platforms: %i[mri mingw x64_mingw]

  # Add testing gems
  gem 'factory_bot_rails'
  gem 'faker'
  gem 'rails-controller-testing'
  gem 'rspec-rails'
end

group :development do
  # Use console on exceptions pages [https://github.com/rails/web-console]
  gem 'web-console', '4.2.0'

  # Add speed badges [https://github.com/MiniProfiler/rack-mini-profiler]
  # gem "rack-mini-profiler"

  # Speed up commands on slow machines / big apps [https://github.com/rails/spring]
  # gem "spring"

  # Rubocop and its extensions
  gem 'rubocop', require: false
  gem 'rubocop-capybara', require: false
  gem 'rubocop-factory_bot', require: false
  gem 'rubocop-rails', require: false
  gem 'rubocop-rspec', require: false
  gem 'rubocop-rspec_rails', require: false
end

group :test do
  # Use system testing [https://guides.rubyonrails.org/testing.html#system-testing]
  gem 'capybara', '3.39.0'
  gem 'selenium-webdriver', '4.8.6'
  gem 'webdrivers'

  # For test coverage reporting
  gem 'simplecov', require: false
  gem 'simplecov-console', require: false

  # For testing validations and associations
  gem 'shoulda-matchers'
end
