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

    
    
    
    if params[:tab] == nil || params[:tab].to_i < 0
      params[:tab] = 0
    end
    
    params[:tab] = params[:tab].to_i
    all_workouts = Workout.where(user_id: userList).order(:started_at).reverse_order
    
    @feed = all_workouts[params[:tab]...params[:tab]+30]

    @max = all_workouts.count.floor
  end
end
