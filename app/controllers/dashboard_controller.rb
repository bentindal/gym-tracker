class DashboardController < ApplicationController
  def view
    @page_title = "Dashboard"
    @page_description = "View your dashboard on GymTracker"
    @location = "dashboard"

    userList = [current_user]
    list_of_ids = Friend.where(user: current_user.id, confirmed: true).pluck(:follows)
    # Feed
    @feed = []
    all_workouts = Workout.where(user_id: list_of_ids) + Workout.where(user_id: current_user.id)
    all_workouts.each do |workout|
      @feed.push(workout.feed)
    end
    
    @feed = @feed.sort_by { |a| a[0] }.reverse[0..2]

    # Other information
    @dates = []
    current_user.sets.each do |workout|
        @dates.push(workout.created_at.to_date)
    end
    
    # Now for calendar view, default = current month
    if params[:month] != nil && params[:month].to_i > 0 && params[:month].to_i < 13
      # If month is specified
      @month = params[:month].to_i
    else
        @month = Date.today.month
    end
    # Month name @month
    @month_name = Date::MONTHNAMES[@month]
  end
end
