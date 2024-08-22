# spec/factories/users.rb
FactoryBot.define do
  factory :user do
    name { "Test User" }
    sequence(:email) { |n| "test#{n}@example.com" }
    password { "Password1!" }
    password_confirmation { "Password1!" }
  end
end
