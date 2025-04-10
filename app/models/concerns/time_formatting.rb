# frozen_string_literal: true

# Module for formatting time differences into human-readable strings
module TimeFormatting
  extend ActiveSupport::Concern

  def format_time_diff(time_diff)
    if time_diff < 3600 # Less than 1 hour
      format_minutes(time_diff)
    elsif time_diff < 86_400 # Less than 1 day
      format_hours(time_diff)
    elsif time_diff < 604_800 # Less than 1 week
      format_days(time_diff)
    elsif time_diff < 2_592_000 # Less than 1 month (30 days)
      format_weeks(time_diff)
    else
      'over a month ago'
    end
  end

  private

  def format_minutes(time_diff)
    minutes = (time_diff / 60.0).round
    "#{minutes} minute#{'s' unless minutes == 1} ago"
  end

  def format_hours(time_diff)
    hours = (time_diff / 3600.0).round
    "#{hours} hour#{'s' unless hours == 1} ago"
  end

  def format_days(time_diff)
    days = (time_diff / 86_400.0).round
    "#{days} day#{'s' unless days == 1} ago"
  end

  def format_weeks(time_diff)
    weeks = (time_diff / 604_800.0).round
    "#{weeks} week#{'s' unless weeks == 1} ago"
  end
end
