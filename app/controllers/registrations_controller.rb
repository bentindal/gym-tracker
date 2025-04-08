# frozen_string_literal: true

# The RegistrationsController extends Devise's RegistrationsController to customize
# the sign-up and account update processes for GymTracker users.
class RegistrationsController < Devise::RegistrationsController
  def new
    @page_title = t('.page_title')
    @page_description = t('.page_description')
    super
  end

  private

  def sign_up_params
    params.require(:user).permit(:first_name, :last_name, :email, :isPublic, :password, :password_confirmation,
                                 :name)
  end

  def account_update_params
    params.require(:user).permit(:first_name, :last_name, :email, :isPublic, :password, :name,
                                 :current_password)
  end
end
