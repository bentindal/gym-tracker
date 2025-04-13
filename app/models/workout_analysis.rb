# frozen_string_literal: true

class WorkoutAnalysis < ApplicationRecord
  belongs_to :workout
  validates :total_volume, presence: true
  validates :total_sets, presence: true
  validates :total_reps, presence: true
  validates :average_weight, presence: true
end
