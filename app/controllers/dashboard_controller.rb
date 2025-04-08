# frozen_string_literal: true

class DashboardController < ApplicationController
  def view
    @page_title = 'Dashboard'
    @page_description = 'View your dashboard on GymTracker'
    @location = 'dashboard'

    [current_user]
    list_of_ids = Friend.where(user: current_user.id, confirmed: true).pluck(:follows)
    # Feed

    @feed = []
    all_workouts = Workout.where(user_id: list_of_ids) + Workout.where(user_id: current_user.id)
    all_workouts.each do |workout|
      @feed.push(workout)
    end

    # Sort by started_at date
    @feed = @feed.sort_by(&:started_at).reverse[0...5]

    # Other information
    @dates = []
    current_user.sets.each do |workout|
      @dates.push(workout.created_at.to_date)
    end

    # Now for calendar view, default = current month
    if !params[:month].nil? && params[:month].to_i.positive? && params[:month].to_i < 13 && !params[:year].nil? && params[:year].to_i > 2020 && params[:year].to_i < 3000
      # If month is specified
      @month = params[:month].to_i
      @year = params[:year].to_i
    else
      @month = Date.today.month
      @year = Date.today.year
    end
    # Month name @month
    @month_name = Date::MONTHNAMES[@month]
  end
end
