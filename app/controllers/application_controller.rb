class ApplicationController < ActionController::Base
    # Require user to be logged in before any action except for home#index not just index
    before_action :authenticate_user!, except: [:index]

    protect_from_forgery with: :exception
end
