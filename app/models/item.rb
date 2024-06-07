class Item < ApplicationRecord
  belongs_to :user
  has_many :send_lists

  validates :title, presence: true, length: { maximum: 255 }
  validates :item_url, presence: true, length: { maximum: 255 }
  # 説明欄は必須ではない
  validates :description, length: { maximum: 255 }, allow_blank: true
  
end
