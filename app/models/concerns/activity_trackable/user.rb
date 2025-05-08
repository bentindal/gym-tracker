# frozen_string_literal: true

module ActivityTrackable
  module User
    extend ActiveSupport::Concern

    def midworkout
      return false if sets.empty?

      sets.where(belongs_to_workout: nil).exists?
    end

    def last_exercise
      return nil if sets.empty?

      sets.last.exercise
    end

    def last_set
      return nil if sets.empty?

      sets.last
    end

    def last_seen
      return nil if sets.empty?

      last = last_set.created_at
      return 'over a month ago' if last <= 1.month.ago

      if last <= 1.week.ago
        weeks = ((Time.zone.now - last) / 1.week).round
        return "#{weeks} week ago" if weeks == 1

        "#{weeks} weeks ago"
      elsif last <= 1.day.ago
        days = ((Time.zone.now - last) / 1.day).round
        return "#{days} day ago" if days == 1

        "#{days} days ago"
      elsif last <= 1.hour.ago
        hours = ((Time.zone.now - last) / 1.hour).round
        return "#{hours} hour ago" if hours == 1

        "#{hours} hours ago"
      else
        minutes = ((Time.zone.now - last) / 1.minute).round
        return "#{minutes} minute ago" if minutes == 1

        "#{minutes} minutes ago"
      end
    end

    def workout_count
      workouts.count
    end

    def last_active
      last_workout = workouts.order(started_at: :desc).first&.started_at
      last_set_time = sets.order(created_at: :desc).first&.created_at

      return nil unless last_workout || last_set_time

      [last_workout, last_set_time].compact.max
    end
  end
end
