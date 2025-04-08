# frozen_string_literal: true

# The UsersController manages user profiles and provides functionality to view
# and search for users on GymTracker.
class UsersController < ApplicationController
  def view
    load_user_profile
    load_feed
    load_exercises_and_workouts
    check_friendship_status
    set_calendar_data
  end

  def find
    @page_title = t('.page_title')
    @page_description = t('.page_description')
    @users = User.order(:first_name)
  end

  private

  def load_user_profile
    @user = User.find(params[:id])
    @location = 'dashboard'
    @page_title = t('users.view.page_title', name: "#{@user.first_name} #{@user.last_name}")
    @page_description = t('users.view.page_description', name: "#{@user.first_name} #{@user.last_name}")
  end

  def load_feed
    @feed = Workout.where(user_id: @user.id).order(started_at: :desc).limit(3)
  end

  def load_exercises_and_workouts
    @exercises = Exercise.where(user_id: @user.id)
    @workouts = Allset.where(user_id: @user.id)
  end

  def check_friendship_status
    return if current_user.nil?

    @is_friend = Friend.exists?(user: current_user.id, follows: @user.id, confirmed: true)
    @pending = Friend.exists?(user: current_user.id, follows: @user.id, confirmed: false)
    @follows_back = Friend.exists?(follows: current_user.id, user: @user.id, confirmed: true)
  end

  def set_calendar_data
    if valid_month_and_year_params?
      @month = params[:month].to_i
      @year = params[:year].to_i
    else
      today = Time.zone.today
      @month = today.month
      @year = today.year
    end

    @month_name = I18n.t('date.month_names')[@month]
  end

  def valid_month_and_year_params?
    params[:month].to_i.between?(1, 12) && params[:year].to_i.between?(2021, 2999)
  end
end
