class Item < ApplicationRecord
  belongs_to :user
  has_many :send_lists, dependent: :nullify

  acts_as_taggable_on :tags
  validate :validate_tag_limit

  validates :title, presence: true, length: { maximum: 255 }
  validates :item_url, presence: true, length: { maximum: 255 }, uniqueness: { case_sensitive: true }
  # 説明欄は必須ではない
  validates :description, length: { maximum: 255 }, allow_blank: true

  private

  def validate_tag_limit
    errors.add(:tag_list, "can only have up to 3 tags") if tag_list.size > 3
  end

end
