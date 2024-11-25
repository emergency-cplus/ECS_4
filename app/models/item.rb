class Item < ApplicationRecord
  belongs_to :user
  has_many :send_lists, dependent: :nullify

  acts_as_taggable_on :tags
  validate :validate_tag_limit
  
  # YouTube Shorts URL のバリデーションを追加
  # validate :validate_youtube_shorts_url

  validates :title, presence: true, length: { maximum: 255 }
  validates :item_url, presence: true, length: { maximum: 255 }, uniqueness: { case_sensitive: true }
  # 説明欄は必須ではない
  validates :description, length: { maximum: 255 }, allow_blank: true

  def normalized_tag_list=(tag_string)
    return if tag_string.blank?
    
    # 全角スペース、半角スペース、句点、カンマを区切り文字として扱う
    normalized_tags = tag_string.gsub(/[、,]/, ' ').split(/\s+/).uniq
    self.tag_list = normalized_tags
  end

  private

  def validate_tag_limit
    if tag_list.size > 3
      errors.add(:tag_list, :too_many_tags) 
    end
  end

  def validate_youtube_shorts_url
    return if item_url.blank?
    
    # URLからクエリパラメータやハッシュを許容する形に修正
    # YouTube動画IDは必ず11文字という仕様に準拠
    unless item_url.match?(/\Ahttps:\/\/(?:www\.)?youtube\.com\/shorts\/[a-zA-Z0-9_-]{11}/)
      errors.add(:item_url, :invalid_youtube_shorts_url)
    end
  end
  
end
