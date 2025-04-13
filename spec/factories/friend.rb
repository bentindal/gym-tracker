# frozen_string_literal: true

FactoryBot.define do
  factory :friend do
    follower factory: %i[user]
    followed factory: %i[user]
    confirmed { false }
  end
end
