class DashboardController < ApplicationController
  def view
    @feed = current_user.feed
    @month_name = Date.today.strftime("%B")
    @month = Date.today.strftime("%m").to_i
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
  end
end
