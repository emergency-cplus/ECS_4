class Item < ApplicationRecord
  JAPANESE_SEPARATORS = /[、,\/]/

  belongs_to :user
  has_many :send_lists, dependent: :nullify

  acts_as_taggable_on :tags
  validate :validate_tag_limit
  validate :validate_youtube_shorts_url
  before_validation :standardize_youtube_url

  validates :title, presence: true, length: { maximum: 255 }
  validates :item_url, presence: true, length: { maximum: 255 }
  validates :description, length: { maximum: 255 }, allow_blank: true

  def tag_list=(tag_string)
    return if tag_string.blank?

    begin
      Rails.logger.debug "Original tag string: #{tag_string.inspect}"

      tag_string = tag_string.to_s.encode('UTF-8', invalid: :replace, undef: :replace, replace: '')
      Rails.logger.debug "After encoding: #{tag_string.inspect}"

      # 全角・半角スペースを削除
      tag_string = tag_string.gsub(/[\s\u3000]/, '')
      Rails.logger.debug "After removing spaces: #{tag_string.inspect}"

      normalized_tags = tag_string.gsub(JAPANESE_SEPARATORS, ',')
                                  .split(',')
                                  .map { |tag| normalize_tag(tag) }
                                  .reject(&:blank?)
                                  .uniq

      Rails.logger.debug "Final normalized tags: #{normalized_tags.inspect}"

      # 親クラスの `tag_list=` メソッドを呼び出す
      super(normalized_tags)
    rescue EncodingError => e
      Rails.logger.error "Tag encoding error: #{e.message}"
      super([])
    end
  end

  private

  def normalize_tag(tag)
    tag.strip.unicode_normalize(:nfkc)
  end

  # タグ数のバリデーションを修正（4つ以上でエラー）
  def validate_tag_limit
    if tag_list.size >= 4
      errors.add(:tag_list, :too_many_tags)
    end
  end
  
  def extract_video_id(url)
    # YouTube ShortsのURLから動画IDを抽出
    match_data = url.match(/youtube\.com\/shorts\/([a-zA-Z0-9_-]{11})/)
    match_data ? match_data[1] : nil
  end

  def standardize_youtube_url
    return if item_url.blank?

    video_id = extract_video_id(item_url)
    if video_id
      self.item_url = "https://youtube.com/shorts/#{video_id}"
    end
  end

  def validate_youtube_shorts_url
    return if item_url.blank?

    video_id = extract_video_id(item_url)
    unless video_id
      errors.add(:item_url, :invalid_youtube_shorts_url)
      return
    end

    # 自分以外で同じ動画IDを持つレコードが存在するかチェック
    existing_item = Item.where.not(id: id)
                        .where(user_id: user_id) # ユーザーIDの条件を追加
                        .where("item_url LIKE ?", "%/shorts/#{video_id}%")
                        .first

    if existing_item
      errors.add(:item_url, :duplicate_video)
    end
  end
end
