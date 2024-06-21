class SendList < ApplicationRecord
  belongs_to :item
  belongs_to :user

  validates :phone_number, presence: true
  validates :sender, presence: true
  
end