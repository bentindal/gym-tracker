# frozen_string_literal: true

module Users
  class SessionsController < Devise::SessionsController
    # before_action :configure_sign_in_params, only: [:create]

    # GET /resource/sign_in
    # def new
    #   super
    # end

    # POST /resource/sign_in
    def create
      self.resource = warden.authenticate!(auth_options)
      set_flash_message!(:notice, :signed_in)
      sign_in(resource_name, resource)
      yield resource if block_given?
      respond_with resource, location: after_sign_in_path_for(resource)
    rescue Devise::Strategies::DatabaseAuthenticatable::InvalidPassword
      flash.now[:alert] = 'Invalid email or password.'
      self.resource = resource_class.new(sign_in_params)
      render :new
    end

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
