class FeedController < ApplicationController
  def view
    @page_title = "Feed"
    @page_description = "View all your & your friends workouts on GymTracker"

    from = 0
    to = 10
    userList = [current_user]
    if params[:filter] != 'you'
      list_of_ids = Friend.where(user: current_user.id, confirmed: true).pluck(:follows)
      list_of_ids.each do |id|
        userList.push(User.find(id))
      end
    end

    @feed = []
    if params[:from] != nil && params[:to] != nil
      from = params[:from].to_i
      to = params[:to].to_i
      all_workouts = Workout.where(user_id: userList).order(:created_at).reverse_order[from...to]
    else
      all_workouts = Workout.where(user_id: userList).order(:created_at).reverse_order
    end

    @workouts_processed = 0

    all_workouts.each do |workout|
      @feed.push(workout.feed)
      @workouts_processed += 1
    end
    
    @feed = @feed.sort_by { |a| a[0] }.reverse
  end
end
