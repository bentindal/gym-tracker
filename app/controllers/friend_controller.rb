# frozen_string_literal: true

# The FriendController manages friend relationships, including listing friends,
# adding, confirming, and removing friendships.
class FriendController < ApplicationController
  def list
    set_page_metadata('Friends', 'View your friends on GymTracker')
    load_pending_followers
    load_pending_following
    load_actual_followers
    load_actual_following
  end

  def add
    @friend = Friend.new(user: current_user.id, follows: params[:id])
    @friend.confirmed = true if User.find_by(id: params[:id])&.is_public
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

  private

  def set_page_metadata(title, description)
    @page_title = title
    @page_description = description
  end

  def load_pending_followers
    @pending_followers = User.joins(:friends).where(friends: { follows: current_user.id, confirmed: false })
  end

  def load_pending_following
    @pending_following = User.joins(:friends).where(friends: { user: current_user.id, confirmed: false })
  end

  def load_actual_followers
    @actual_followers = User.joins(:friends).where(friends: { follows: current_user.id, confirmed: true })
  end

  def load_actual_following
    @actual_following = User.joins(:friends).where(friends: { user: current_user.id, confirmed: true })
  end

  def user_view_path(user_id)
    "/users/view?id=#{user_id}"
  end

  def friend_list_path
    '/friend/list'
  end
end
