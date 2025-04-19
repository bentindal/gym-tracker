# frozen_string_literal: true

FactoryBot.define do
  factory :workout do
    user
    title { 'Test Workout' }
    started_at { Time.current }
    ended_at { Time.current + 1.hour }
    deleted_at { nil }
  end
end
