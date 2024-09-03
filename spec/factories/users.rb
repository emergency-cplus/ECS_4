# spec/factories/users.rb
FactoryBot.define do
  factory :user do
    name { "Test User" }
    sequence(:email) { |n| "test#{n}@example.com" }
    password { "Password1!" }
    password_confirmation { "Password1!" }
    uuid { SecureRandom.uuid }  # UUID をランダムに生成
  end
end
