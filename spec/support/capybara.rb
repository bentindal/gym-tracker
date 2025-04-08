# frozen_string_literal: true

# Configure Capybara for system tests
RSpec.configure do |config|
  config.before(:each, type: :system) do
    driven_by :selenium_chrome_headless
  end
end
