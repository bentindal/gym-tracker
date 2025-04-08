FactoryBot.define do
  factory :allset do
    exercise_id { create(:exercise).id }
    weight { 100 }
    repetitions { 10 }
    isWarmup { false }
    created_at { Time.current }
    user_id { Exercise.find(exercise_id).user_id }
    
    trait :warmup do
      isWarmup { true }
      weight { 50 }
    end
    
    trait :heavy do
      weight { 150 }
      repetitions { 5 }
    end
    
    trait :light do
      weight { 60 }
      repetitions { 15 }
    end
    
    trait :past do
      created_at { 7.days.ago }
    end
    
    trait :recent do
      created_at { 1.day.ago }
    end
  end
end
