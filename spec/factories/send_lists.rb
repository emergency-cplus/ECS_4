FactoryBot.define do
  factory :send_list do
    association :user
    association :item
    phone_number { "09012345678" }
    send_at { 1.day.from_now }
    sender { "Test Sender" }
    send_as_test { false }
  end
end
