# spec/factories/items.rb
FactoryBot.define do
    factory :item do
      association :user
      sequence(:title) { |n| "テストアイテム#{n}" }
      description { "これはテストアイテムの説明です。" }
      sequence(:item_url) { |n| "https://www.youtube.com/shorts/abc#{n}def" }
    end
  end
  