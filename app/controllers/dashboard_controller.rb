# frozen_string_literal: true

# The DashboardController manages the user's dashboard view, providing an overview
# of recent activities, workouts, and a calendar view for tracking progress.
class DashboardController < ApplicationController
  def view
    set_page_metadata
    load_feed
    load_calendar_data
  end

  private

  def set_page_metadata
    @page_title = 'Dashboard'
    @page_description = 'View your dashboard on GymTracker'
    @location = 'dashboard'
  end

  def load_feed
    friend_ids = Friend.where(user: current_user.id, confirmed: true).pluck(:follows)
    workouts = Workout.where(user_id: friend_ids + [current_user.id])
    @feed = workouts.order(started_at: :desc).limit(5)
  end

  def load_calendar_data
    @dates = current_user.sets.pluck(:created_at).map(&:to_date)
    set_month_and_year
    @month_name = I18n.t('date.month_names')[@month]
  end

  def set_month_and_year
    if valid_month_and_year_params?
      @month = params[:month].to_i
      @year = params[:year].to_i
    else
      today = Time.zone.today
      @month = today.month
      @year = today.year
    end
  end

  def valid_month_and_year_params?
    params[:month].to_i.between?(1, 12) && params[:year].to_i.between?(2021, 2999)
  end
end
