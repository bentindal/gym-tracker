# frozen_string_literal: true

FactoryBot.define do
  factory :exercise do
    name { 'Bench Press' }
    group { 'Chest' }
    unit { 'lbs' }
    user_id { create(:user).id }

    trait :back_exercise do
      name { 'Pull Up' }
      group { 'Back' }
    end

    trait :leg_exercise do
      name { 'Squat' }
      group { 'Legs' }
    end

    trait :shoulder_exercise do
      name { 'Shoulder Press' }
      group { 'Shoulders' }
    end

    trait :arm_exercise do
      name { 'Bicep Curl' }
      group { 'Biceps' }
    end

    trait :tricep_exercise do
      name { 'Tricep Extension' }
      group { 'Triceps' }
    end

    trait :other_exercise do
      name { 'Crunches' }
      group { 'Core' }
    end
  end
end
