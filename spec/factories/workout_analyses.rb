# frozen_string_literal: true

FactoryBot.define do
  factory :workout_analysis do
    workout
    feedback { 'Test feedback about the workout' }
    total_volume { 1000.0 }
    total_sets { 10 }
    total_reps { 100 }
    average_weight { 50.0 }
  end
end
