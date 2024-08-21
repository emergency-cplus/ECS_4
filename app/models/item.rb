class Item < ApplicationRecord
  belongs_to :user
  has_many :send_lists, dependent: :nullify

  acts_as_taggable_on :tags
  validate :validate_tag_limit
  
  # YouTube Shorts URL のバリデーションを追加
  validate :validate_youtube_shorts_url

  validates :title, presence: true, length: { maximum: 255 }
  validates :item_url, presence: true, length: { maximum: 255 }, uniqueness: { case_sensitive: true }
  # 説明欄は必須ではない
  validates :description, length: { maximum: 255 }, allow_blank: true

  private

  def validate_tag_limit
    errors.add(:tag_list, "can only have up to 3 tags") if tag_list.size > 3
  end

# youtube shorts urlのバリデーション詳細
  # def validate_youtube_shorts_url
  #   return if item_url.blank?
  #   unless item_url.match?(/\Ahttps:\/\/(?:www\.)?youtube\.com\/shorts\/[a-zA-Z0-9_-]+\z/)
  #     errors.add(:item_url, :invalid_youtube_shorts_url)
  #   end
  # end
  def validate_youtube_shorts_url
    Rails.logger.debug "Validating URL: #{item_url}"
    unless item_url.match?(/\Ahttps:\/\/(?:www\.)?youtube\.com\/shorts\/[a-zA-Z0-9_-]+\z/)
      Rails.logger.debug "Invalid YouTube Shorts URL detected."
      errors.add(:item_url, :invalid_youtube_shorts_url)
    end
  end  
end
