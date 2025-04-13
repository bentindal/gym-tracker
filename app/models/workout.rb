# frozen_string_literal: true

# Represents a workout session in the system
# Contains information about when the workout started and ended,
# and manages the sets that belong to it
class Workout < ApplicationRecord
  belongs_to :user
  has_many :exercises, dependent: :destroy
  has_one :workout_analysis, dependent: :destroy
  validates :title, presence: true

  def allsets
    Allset.where(belongs_to_workout: id)
  end

  def feed
    # Put into feed format [date, user, [[exercises, sets]]]
    @feed = []
    # Get all sets that belong_to_workout this
    all_sets = Allset.where(belongs_to_workout: id)
    # Split all_sets into groups by exercise
    all_sets_by_exercise = all_sets.group_by(&:exercise)
    # Change from hash to list
    all_sets_by_exercise.to_a
  end

  def likes_count
    Like.where(workout_id: id).length
  end

  def liked_by
    # List of users who liked this workout as their names
    @liked_by = []
    likes = Like.where(workout_id: id)
    likes.each do |like|
      user = User.find(like.user_id)
      @liked_by.push(user.name)
    end
    @liked_by
  end

  def user
    User.find(user_id)
  end

  def group_colour
    Allset.where(belongs_to_workout: id).first.exercise.group_colour
  end

  def length_string
    length_in_seconds = (ended_at - started_at).to_i
    # Convert to hr, min, sec
    hours = length_in_seconds / 3600
    minutes = (length_in_seconds - (hours * 3600)) / 60
    seconds = length_in_seconds - (hours * 3600) - (minutes * 60)
    # Convert to string
    if hours.positive?
      "#{hours}h #{minutes}m #{seconds}s"
    else
      "#{minutes}m #{seconds}s"
    end
  end
end
