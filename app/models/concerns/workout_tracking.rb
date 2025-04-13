# frozen_string_literal: true

# Provides methods for tracking workouts and managing workout-related functionality
module WorkoutTracking
  extend ActiveSupport::Concern

  included do
    has_many :workouts, dependent: :destroy
  end

  def last_workout
    workouts.order(started_at: :desc).first
  end

  def last_workout_date
    last_workout&.started_at&.to_date
  end

  def last_workout_time
    last_workout&.started_at
  end

  def in_workout?
    return false if last_set.nil?
    return true if last_set.workout.nil?

    false
  end

  def current_workout_duration
    return 0 if last_set.nil?
    return 0 unless in_workout?

    (Time.zone.now - last_set.created_at).to_i
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
    return false if last_set.nil?
    return false unless in_workout?

    # Get all unassigned sets
    unassigned_sets = sets.where(workout_id: nil)

    # Create a new workout
    workout = Workout.new(
      user: self,
      started_at: unassigned_sets.first.created_at,
      ended_at: Time.zone.now,
      title: "Workout on #{Time.zone.now.strftime('%A')}",
      exercises_used: unassigned_sets.group_by(&:exercise).length,
      sets_completed: unassigned_sets.length
    )

    if workout.save
      # Assign all sets to this workout
      unassigned_sets.each { |set| set.update!(workout: workout) }
      true
    else
      false
    end
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
