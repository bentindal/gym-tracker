# frozen_string_literal: true

FactoryBot.define do
  factory :allset do
    exercise
    user
    weight { 100.0 }
    repetitions { 10 }
    belongs_to_workout { nil }
    isWarmup { false }
    created_at { Time.current }

    trait :with_workout do
      transient do
        workout { nil }
      end

      after(:build) do |allset, evaluator|
        allset.belongs_to_workout = evaluator.workout&.id
      end
    end

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
