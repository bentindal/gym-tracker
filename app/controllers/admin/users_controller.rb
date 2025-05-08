# frozen_string_literal: true

module Admin
  class UsersController < ApplicationController
    before_action :authenticate_user!
    before_action :require_admin
    before_action :set_user, only: %i[edit update destroy]

    def edit
      @page_title = "Edit User - #{@user.name}"
      @page_description = 'Edit user details and role'
    end

    def update
      if @user.update(user_params)
        redirect_to admin_dashboard_path, notice: 'User was successfully updated.'
      else
        render :edit
      end
    end

    def destroy
      if @user == current_user
        redirect_to admin_dashboard_path, alert: 'You cannot delete your own account.'
      else
        @user.destroy
        redirect_to admin_dashboard_path, notice: 'User was successfully deleted.'
      end
    end

    private

    def set_user
      @user = User.find(params[:id])
    end

    def user_params
      params.require(:user).permit(:first_name, :last_name, :email, :role)
    end

    def require_admin
      return if current_user&.admin?

      flash[:alert] = 'You are not authorized to access this area.'
      redirect_to root_path
    end
  end
end
