FactoryBot.define do
  factory :workout_analysis do
    workout
    feedback { "Test analysis feedback" }
    total_volume { 1000 }
    total_sets { 10 }
    total_reps { 100 }
    average_weight { 50 }
  end
end 