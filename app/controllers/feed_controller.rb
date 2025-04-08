# frozen_string_literal: true

# The FeedController manages the user's feed, displaying workouts from the user
# and their friends, with options to filter and paginate the results.
class FeedController < ApplicationController
  def view
    set_page_metadata('Feed', 'View all your & your friends workouts on GymTracker')
    load_user_list
    load_feed
  end

  private

  def set_page_metadata(title, description)
    @page_title = title
    @page_description = description
    @location = 'feed'
  end

  def load_user_list
    @user_list = [current_user]
    return if params[:filter] == 'you'

    friend_ids = Friend.where(user: current_user.id, confirmed: true).pluck(:follows)
    @user_list += User.where(id: friend_ids)
  end

  def load_feed
    params[:tab] = params[:tab].to_i.clamp(0, Float::INFINITY)
    all_workouts = Workout.where(user_id: @user_list).order(started_at: :desc)

    @feed = all_workouts.offset(params[:tab]).limit(10)
    @max = all_workouts.count
  end
end
