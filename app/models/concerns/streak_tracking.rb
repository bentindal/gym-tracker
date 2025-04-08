# frozen_string_literal: true

# Module for tracking workout streaks
module StreakTracking
  extend ActiveSupport::Concern

  def streak_count
    sets = Allset.where(user_id: id).order(created_at: :desc)
    return 0 if sets.empty?

    calculate_streak(start_date_for_streak)
  end

  def streak_status
    return 'active' if worked_out_today?
    return 'pending' if worked_out_yesterday?
    return 'at_risk' if worked_out_two_days_ago?

    'none'
  end

  def worked_out_today?
    all_workouts = sets
    all_workouts.each do |workout|
      return true if workout.created_at.strftime('%d/%m') == Time.zone.today.strftime('%d/%m')
    end
    false
  end

  def worked_out_yesterday?
    worked_out_on_date(Date.yesterday.day, Date.yesterday.month, Date.yesterday.year)
  end

  def worked_out_two_days_ago?
    worked_out_on_date(Date.yesterday.yesterday.day, Date.yesterday.yesterday.month, Date.yesterday.yesterday.year)
  end

  def worked_out_on_date(day, month, year)
    all_workouts = sets
    # Pad day and month values with a 0 if they are less than 10
    day = "0#{day}" if day.to_i < 10
    month = "0#{month}" if month.to_i < 10

    all_workouts.each do |workout|
      return true if workout.created_at.strftime('%d/%m/%Y') == "#{day}/#{month}/#{year}"
    end
    false
  end

  private

  def start_date_for_streak
    if worked_out_today?
      Time.zone.today
    else
      Date.yesterday
    end
  end

  def calculate_streak(start_date)
    date_pointer = start_date
    streak_count = 0
    gaps_used = 0

    loop do
      break if streak_ended?(gaps_used)

      if worked_out_on_date(date_pointer.day, date_pointer.month, date_pointer.year)
        streak_count += 1
        gaps_used = 0
      else
        gaps_used += 1
      end
      date_pointer -= 1
    end

    streak_count
  end

  def streak_ended?(gaps_used)
    gaps_used > 1
  end
end
