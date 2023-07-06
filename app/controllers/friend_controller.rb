class FriendController < ApplicationController
  def list
    @page_title = "Friends"
    @page_description = "View your friends on GymTracker"
    # Incoming
    pending_followers = Friend.where(follows: current_user.id, confirmed: false)

    @pending_followers = []
    pending_followers.each do |follower|
      @pending_followers.push(User.find(follower.user))
    end

    # Outgoing
    pending_following = Friend.where(user: current_user.id, confirmed: false)

    @pending_following = []
    pending_following.each do |following|
      @pending_following.push(User.find(following.follows))
    end

    # Followers
    actual_followers = Friend.where(follows: current_user.id, confirmed: true)

    @actual_followers = []
    actual_followers.each do |follower|
      @actual_followers.push(User.find(follower.user))
    end

    # Following
    actual_following = Friend.where(user: current_user.id, confirmed: true)

    @actual_following = []
    actual_following.each do |following|
      @actual_following.push(User.find(following.follows))
    end

  end

  def add
    @friend = Friend.new
    @friend.user = current_user.id
    @friend.follows = params[:id]
    if User.find_by(id: params[:id]).isPublic
      @friend.confirmed = true
    end
    @friend.save
    redirect_to "/users/view?id=#{params[:id]}"
  end

  def confirm
    @friend = Friend.find_by(user: params[:id], follows: current_user.id)
    @friend.confirmed = true
    @friend.save
    redirect_to "/friend/list"
  end

  def remove
    @friend = Friend.find_by(user: current_user.id, follows: params[:id])
    @friend.destroy
    redirect_to "/users/view?id=#{params[:id]}"
  end

  def remove_follower
    @friend = Friend.find_by(user: params[:id], follows: current_user.id)
    @friend.destroy
    redirect_to "/friend/list"
  end
end
