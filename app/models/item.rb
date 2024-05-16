class Item < ApplicationRecord
  belongs_to :user

  validates :title, presence: true, length: { maximum: 255 }
  validates :item_url, presence: true, length: { maximum: 255 }
  # 説明欄は必須ではない
  validates :description, length: { maximum: 255 }, allow_blank: true
  
end
