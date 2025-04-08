FactoryBot.define do
  factory :user do
    sequence(:email) { |n| "user#{n}@example.com" }
    password { "password" }
    first_name { "John" }
    last_name { "Doe" }
  end
end 