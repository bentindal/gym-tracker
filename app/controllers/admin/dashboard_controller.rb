module Admin
  class DashboardController < ApplicationController
    before_action :authenticate_user!
    before_action :require_admin

    def index
      @page_title = 'Admin Dashboard'
      @page_description = 'Manage your application settings and users'
      @users = User.all
      @total_users = User.count
      @total_workouts = Workout.count
      @total_sets = Allset.count
    end

    private

    def require_admin
      unless current_user&.admin?
        flash[:alert] = 'You are not authorized to access this area.'
        redirect_to root_path
      end
    end
  end
end
