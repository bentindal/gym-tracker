# frozen_string_literal: true

# The ApplicationController serves as the base controller for all other controllers.
# It includes common functionality such as user authentication and CSRF protection.
class ApplicationController < ActionController::Base
  before_action :authenticate_user!, except: %i[index new create]
  before_action :set_location
  
  # Handle CSRF protection for GitHub Codespaces
  protect_from_forgery with: :exception, unless: :github_codespaces?

  def index
    # Define the index action explicitly to satisfy RuboCop's LexicallyScopedActionFilter.
  end

  private

  def set_location
    referrer = request.referrer
    return unless referrer

    if referrer.include?('/feed')
      @location = '/feed'
    elsif referrer.include?('/dashboard')
      @location = '/dashboard'
    elsif referrer.include?('/users/view')
      # Extract user ID from the referrer URL
      if referrer =~ /\/users\/view\?id=(\d+)/
        @location = "/users/view?id=#{$1}"
      end
    end
  end

  def github_codespaces?
    ENV['CODESPACES'] == 'true' || request.base_url.include?('github.dev')
  end
end
