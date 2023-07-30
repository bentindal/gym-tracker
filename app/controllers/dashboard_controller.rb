class DashboardController < ApplicationController
  def view
    @page_title = "Dashboard"
    @page_description = "View your dashboard on GymTracker"
    # Feed
    @feed = []
    userList = [current_user]
    if params[:filter] != 'you'
      list_of_ids = Friend.where(user: current_user.id, confirmed: true).pluck(:follows)
      list_of_ids.each do |id|
        userList.push(User.find(id))
      end
    end
    @feed = []
    userList.each do |user|
      user.feed.each do |feed_item|
        @feed.push(feed_item)
      end
    end
    
    @feed = @feed.sort_by { |a| a[0] }.reverse[0..2]

    # Other information
    @dates = []
    current_user.sets.each do |workout|
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
