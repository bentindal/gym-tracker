# frozen_string_literal: true

module Admin
  class DashboardController < ApplicationController
    before_action :authenticate_user!
    before_action :require_admin

    def index
      @page_title = 'Admin Dashboard'
      @page_description = 'Monitor user activity and manage your application'
      @total_users = User.count
      @total_workouts = Workout.count
      @total_sets = Allset.count
      @users = User.all.order(created_at: :desc)

      if Rails.env.development?
        generate_sample_data
      else
        @user_growth_data = Metric.order(date: :asc).pluck(:date, :total_users).to_h
        # Fetch active users as an array of [date, active_users]
        active_users_array = Metric.order(date: :asc).pluck(:date, :active_users)
        # Calculate 3-day rolling average
        rolling = []
        active_users_array.each_with_index do |(date, value), i|
          window = active_users_array[[i-2,0].max..i].map { |_, v| v }
          avg = window.sum.to_f / window.size
          rolling << [date, avg.round(2)]
        end
        @active_users_data = rolling.to_h
        # Fetch new users as an array of [date, new_users]
        new_users_array = Metric.order(date: :asc).pluck(:date, :new_users)
        new_users_rolling = []
        new_users_array.each_with_index do |(date, value), i|
          window = new_users_array[[i-2,0].max..i].map { |_, v| v }
          avg = window.sum.to_f / window.size
          new_users_rolling << [date, avg.round(2)]
        end
        @new_users_data = new_users_rolling.to_h
        @workouts_data = Metric.order(date: :asc).pluck(:date, :total_workouts).to_h
        @sets_data = Metric.order(date: :asc).pluck(:date, :total_sets).to_h
      end
    end

    private

    def require_admin
      return if current_user&.admin?

      flash[:alert] = 'You are not authorized to access this area.'
      redirect_to root_path
    end

    def generate_sample_data
      # Generate dates for the last 30 days
      dates = (30.days.ago.to_date..Date.today).to_a

      # Generate sample data with realistic patterns
      @user_growth_data = {}
      @active_users_data = {}
      @new_users_data = {}
      @workouts_data = {}
      @sets_data = {}

      dates.each do |date|
        # User Growth - starts at 100 and grows by ~5 per day
        base_users = 100
        growth = (date - 30.days.ago.to_date).to_i * 5
        @user_growth_data[date] = base_users + growth + rand(-2..2)

        # Active Users - around 50 with daily variations
        base_active = 50
        @active_users_data[date] = base_active + rand(-10..10)

        # New Users - around 3 per day with some variation
        base_new = 3
        @new_users_data[date] = base_new + rand(-1..3)

        # Workouts - around 20 per day with some variation
        base_workouts = 20
        workouts = base_workouts + rand(-5..5)
        @workouts_data[date] = workouts

        # Sets - roughly 5 times the number of workouts
        base_sets = workouts * 5
        @sets_data[date] = base_sets + rand(-10..10)
      end
    end
  end
end
