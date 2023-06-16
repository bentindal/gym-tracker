class RegistrationsController < Devise::RegistrationsController

    private
  
        def sign_up_params
            params.require(:user).permit(:first_name, :last_name, :username, :email, :isPublic, :password, :name)
        end
        def account_update_params
            params.require(:user).permit(:first_name, :last_name, :username, :email, :isPublic, :password, :name, :current_password)
        end
  end