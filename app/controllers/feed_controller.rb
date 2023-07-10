class FeedController < ApplicationController
  def view
    @page_title = "Feed"
    @page_description = "View all your & your friends workouts on GymTracker"
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
    
    @feed = @feed.sort_by { |a| a[0] }.reverse
  end
end
