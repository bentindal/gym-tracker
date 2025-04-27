# frozen_string_literal: true

FactoryBot.define do
  factory :workout do
    user
    title { 'Test Workout' }
    started_at { 1.hour.ago }
    ended_at { Time.current }
    deleted_at { nil }
  end
end
