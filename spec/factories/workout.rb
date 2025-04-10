# frozen_string_literal: true

FactoryBot.define do
  factory :workout do
    user
    started_at { 1.hour.ago }
    ended_at { Time.zone.now }
    title { "Workout #{Time.zone.now.strftime('%Y-%m-%d')}" }
    exercises_used { 3 }
    sets_completed { 9 }
  end
end
