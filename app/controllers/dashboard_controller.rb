class DashboardController < ApplicationController
  def view
    @feed = current_user.feed
    @dates = []
    current_user.workouts.each do |workout|
        @dates.push(workout.created_at.to_date)
    end
    @dates = @dates.uniq
    if @feed != []
        @first_exercise = @feed.first[2].first.first
    else
        @first_exercise = nil
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
