# frozen_string_literal: true

# Module for tracking workout-related functionality
# Handles workout status, set management, and workout completion
module WorkoutTracking
  extend ActiveSupport::Concern

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

  def midworkout
    return false if sets == []
    return true if last_set.belongs_to_workout.nil?

    false
  end

  def last_exercise
    return nil if sets == []

    sets.last.exercise
  end

  def last_set
    return nil if sets == []

    sets.last
  end

  def workout_count
    Workout.where(user_id: id).count
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

  def manually_end_workout
    unassigned_sets = Allset.where(user_id: id, belongs_to_workout: nil)
    return if unassigned_sets.empty?

    workout = create_workout_from_sets(unassigned_sets)
    unassigned_sets.each { |set| set.update!(belongs_to_workout: workout.id) }
  end

  private

  def create_workout_from_sets(sets)
    Workout.create!(
      user_id: id,
      start_time: sets.first.created_at,
      end_time: sets.last.created_at
    )
  end
end
