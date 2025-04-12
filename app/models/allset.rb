# frozen_string_literal: true

# The Allset model represents a single set in a workout. It includes associations
# to the user who performed the set and the exercise it belongs to.
class Allset < ApplicationRecord
  belongs_to :user
  belongs_to :exercise
  belongs_to :belongs_to_workout, class_name: 'Workout', optional: true
end
