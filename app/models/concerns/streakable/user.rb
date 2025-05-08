# frozen_string_literal: true

module Streakable
  module User
    extend ActiveSupport::Concern

    def streak_status
      if worked_out_today?
        'active'
      elsif !worked_out_today? && worked_out_on_date(Date.yesterday.day,
                                                     Date.yesterday.month,
                                                     Date.yesterday.year)
        'pending'
      elsif !worked_out_today? && worked_out_on_date(Date.yesterday.yesterday.day,
                                                     Date.yesterday.yesterday.month,
                                                     Date.yesterday.yesterday.year)
        'at_risk'
      else
        'none'
      end
    end

    def worked_out_today?
      workouts.where('started_at >= ?', Time.zone.today.beginning_of_day).exists? ||
        sets.where('created_at >= ?', Time.zone.today.beginning_of_day).exists?
    end

    def streak_msg_other
      case streak_status
      when 'none'
        "#{first_name} hasn't worked out yet today!"
      when 'pending'
        "#{first_name} hasn't worked out today, but has a #{streakcount} day streak going!"
      when 'at_risk'
        "#{first_name} had a day off yesterday, workout today to keep the " \
        "#{streakcount} day streak going or it will be reset!"
      else
        streakcount.zero? ? "#{first_name} worked out today!" : "#{first_name} has a #{streakcount} day streak going!"
      end
    end

    def streak_msg_own
      case streak_status
      when 'none'
        "You haven't got a streak going yet."
      when 'pending'
        "You haven't worked out today, but you have a #{streakcount} day streak!"
      when 'at_risk'
        'You had a day off yesterday, workout today to keep the ' \
        "#{streakcount} day streak going or it will be reset!"
      else
        streakcount.zero? ? 'You worked out today!' : "You have a #{streakcount} day streak!"
      end
    end

    def streakcount
      streak_count
    end

    def worked_out_on_date(day, month, year)
      date = Date.new(year, month, day)
      workouts.where('started_at >= ? AND started_at < ?',
                     date.beginning_of_day,
                     date.end_of_day).exists? ||
        sets.where('created_at >= ? AND created_at < ?',
                   date.beginning_of_day,
                   date.end_of_day).exists?
    end

    def streak_count
      return 0 if workouts.empty? && sets.empty?

      date_pointer = worked_out_today? ? Time.zone.today : Date.yesterday
      streak_count = 0
      gaps_used = 0

      until gaps_used > 1 || (gaps_used == 1 && !worked_out_on_date(date_pointer.day,
                                                                    date_pointer.month,
                                                                    date_pointer.year))
        if worked_out_on_date(date_pointer.day, date_pointer.month, date_pointer.year)
          streak_count += 1
        else
          gaps_used += 1
        end
        date_pointer -= 1.day
      end

      streak_count
    end
  end
end
