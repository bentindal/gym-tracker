# frozen_string_literal: true

# Module for formatting time differences into human-readable strings
module TimeFormatting
  extend ActiveSupport::Concern

  def format_time_diff(time_diff)
    case time_diff
    when (0..(1.hour))
      format_minutes(time_diff)
    when ((1.hour)..(1.day))
      format_hours(time_diff)
    when ((1.day)..(1.week))
      format_days(time_diff)
    when ((1.week)..(1.month))
      format_weeks(time_diff)
    else
      'over a month ago'
    end
  end

  private

  def format_minutes(time_diff)
    minutes = (time_diff / 1.minute).round
    "#{minutes} minute#{'s' unless minutes == 1} ago"
  end

  def format_hours(time_diff)
    hours = (time_diff / 1.hour).round
    "#{hours} hour#{'s' unless hours == 1} ago"
  end

  def format_days(time_diff)
    days = (time_diff / 1.day).round
    "#{days} day#{'s' unless days == 1} ago"
  end

  def format_weeks(time_diff)
    weeks = (time_diff / 1.week).round
    "#{weeks} week#{'s' unless weeks == 1} ago"
  end
end
