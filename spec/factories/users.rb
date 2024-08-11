# spec/factories/users.rb
FactoryBot.define do
  factory :user do
    name { "Test User" }
    email { "test@example.com" }
    password { "Password1!" }
    password_confirmation { "Password1!" }
  end
end
