# frozen_string_literal: true

module Users
  # Controller for handling user authentication sessions
  # Inherits from Devise::SessionsController to provide sign in/out functionality
  class SessionsController < Devise::SessionsController
    # before_action :configure_sign_in_params, only: [:create]

    # GET /resource/sign_in
    # def new
    #   super
    # end

    # POST /resource/sign_in
    # def create
    #   super
    # end

    # DELETE /resource/sign_out
    # def destroy
    #   super
    # end

    # protected
    def new
      @page_title = 'Sign In'
      @page_description = 'Sign in to GymTracker to start tracking your workouts and following your friends.'
      @block_mobile_nav_bar = true
      super
    end
    # If you have extra params to permit, append them to the sanitizer.
    # def configure_sign_in_params
    #   devise_parameter_sanitizer.permit(:sign_in, keys: [:attribute])
    # end
  end
end
