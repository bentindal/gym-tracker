# frozen_string_literal: true

# Module for formatting time differences into human-readable strings
module TimeFormatting
  extend ActiveSupport::Concern

  def format_time_diff(time_diff)
    case time_diff
    when 0...3600 then format_minutes(time_diff)
    when 3600...86_400 then format_hours(time_diff)
    when 86_400...604_800 then format_days(time_diff)
    when 604_800...2_592_000 then format_weeks(time_diff)
    else 'over a month ago'
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
