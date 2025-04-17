# frozen_string_literal: true

# The FriendController manages friend relationships, including listing friends,
# adding, confirming, and removing friendships.
class FriendController < ApplicationController
  before_action :authenticate_user!

  def list
    set_page_metadata('Friends', 'View your friends on GymTracker')
    load_pending_followers
    load_pending_following
    load_followers
    load_following
  end

  def add
    @friend = Friend.new(user: current_user.id, follows: params[:id])
    @friend.confirmed = true if User.find_by(id: params[:id])&.isPublic
    @friend.save
    redirect_to user_view_path(params[:id])
  end

  def confirm
    @friend = Friend.find_by(user: params[:id], follows: current_user.id)
    @friend.update(confirmed: true)
    redirect_to friend_list_path
  end

  def remove
    Friend.find_by(user: current_user.id, follows: params[:id])&.destroy
    redirect_to user_view_path(params[:id])
  end

  def remove_follower
    Friend.find_by(user: params[:id], follows: current_user.id)&.destroy
    redirect_to friend_list_path
  end

  def follow
    @friend = Friend.new(user: current_user.id, follows: params[:id], confirmed: false)
    if @friend.save
      redirect_to friend_list_path, notice: 'Friend request sent!'
    else
      redirect_to friend_list_path, alert: 'Failed to send friend request!'
    end
  end

  def unfollow
    @friend = Friend.find_by(user: current_user.id, follows: params[:id])
    if @friend&.destroy
      redirect_to friend_list_path, notice: 'Unfollowed successfully!'
    else
      redirect_to friend_list_path, alert: 'Failed to unfollow!'
    end
  end

  def accept
    @friend = Friend.find_by(user: params[:id], follows: current_user.id)
    if @friend&.update(confirmed: true)
      redirect_to friend_list_path, notice: 'Friend request accepted!'
    else
      redirect_to friend_list_path, alert: 'Failed to accept friend request!'
    end
  end

  def reject
    @friend = Friend.find_by(user: params[:id], follows: current_user.id)
    if @friend&.destroy
      redirect_to friend_list_path, notice: 'Friend request rejected!'
    else
      redirect_to friend_list_path, alert: 'Failed to reject friend request!'
    end
  end

  private

  def set_page_metadata(title, description)
    @page_title = title
    @page_description = description
  end

  def load_pending_followers
    @pending_followers = User.joins(:passive_friendships)
                            .where(friends: { user: current_user.id, confirmed: false })
  end

  def load_pending_following
    @pending_following = User.joins(:active_friendships)
                            .where(friends: { follows: current_user.id, confirmed: false })
  end

  def load_followers
    @followers = User.joins(:passive_friendships)
                     .where(friends: { user: current_user.id, confirmed: true })
  end

  def load_following
    @following = User.joins(:active_friendships)
                     .where(friends: { follows: current_user.id, confirmed: true })
  end

  def user_view_path(user_id)
    "/users/view?id=#{user_id}"
  end

  def friend_list_path
    '/friend/list'
  end
end
