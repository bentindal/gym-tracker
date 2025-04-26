# frozen_string_literal: true

# The ApplicationController serves as the base controller for all other controllers.
# It includes common functionality such as user authentication and CSRF protection.
class ApplicationController < ActionController::Base
  before_action :authenticate_user!, except: %i[index new create]
  
  # Handle CSRF protection for GitHub Codespaces
  protect_from_forgery with: :exception, unless: :github_codespaces?

  def index
    # Define the index action explicitly to satisfy RuboCop's LexicallyScopedActionFilter.
  end

  private

  def github_codespaces?
    ENV['CODESPACES'] == 'true' || request.base_url.include?('github.dev')
  end
end
