class FeedController < ApplicationController
  def view
    @page_title = "Feed"
    @page_description = "View all your & your friends workouts on GymTracker"
    @location = "feed"
    
    userList = [current_user]
    if params[:filter] != 'you'
      list_of_ids = Friend.where(user: current_user.id, confirmed: true).pluck(:follows)
      list_of_ids.each do |id|
        userList.push(User.find(id))
      end
    end

    @feed = []
    all_workouts = Workout.where(user_id: userList).order(:created_at).reverse_order
    @max = all_workouts.count.floor
    
    if params[:tab] == nil || params[:tab].to_i < 0
      params[:tab] = 0
    end
    
    params[:tab] = params[:tab].to_i

    @workouts_processed = 0

    all_workouts[params[:tab]...params[:tab]+30].each do |workout|
      @feed.push(workout.feed)
      @workouts_processed += 1
    end
    
    @feed = @feed.sort_by { |a| a[0] }.reverse
  end
end
