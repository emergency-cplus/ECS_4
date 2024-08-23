FactoryBot.define do
  factory :send_list do
    phone_number { "123-456-7890" }
    sender { "John Doe" }
    association :item
    association :user
  end
end
