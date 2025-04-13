# frozen_string_literal: true

# The ApplicationController serves as the base controller for all other controllers.
# It includes common functionality such as user authentication and CSRF protection.
class ApplicationController < ActionController::Base
  before_action :authenticate_user!, except: %i[index new create], unless: :devise_controller?

  protect_from_forgery with: :exception

  def index
    # Define the index action explicitly to satisfy RuboCop's LexicallyScopedActionFilter.
  end
end
