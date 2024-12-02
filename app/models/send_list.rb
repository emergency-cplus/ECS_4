class SendList < ApplicationRecord
  belongs_to :item
  belongs_to :user

  # バリデーション
  validates :phone_number, presence: true,
                         format: { with: /\A\d{11}\z/, message: 'は11桁の数字で入力してください' }
  validates :sender, presence: true
  validates :send_at, presence: true

  # スコープ定義
  scope :test_sends, -> { where(send_as_test: true) }
  scope :actual_sends, -> { where(send_as_test: false) }
  scope :in_period, ->(start_date, end_date) {
    where(created_at: start_date.beginning_of_day..end_date.end_of_day)
  }
  scope :for_user, ->(user_id) { where(user_id: user_id) }

  # クラスメソッド
  class << self
    def count_for_user(user_id, include_test: true)
      scope = for_user(user_id)
      scope = scope.actual_sends unless include_test
      scope.count
    end

    def count_for_period(user_id, start_date, end_date, include_test: true)
      scope = for_user(user_id).in_period(start_date, end_date)
      scope = scope.actual_sends unless include_test
      scope.count
    end

    def daily_stats(user_id, days = 30)
      start_date = days.days.ago.beginning_of_day
      for_user(user_id)
        .where('created_at >= ?', start_date)
        .group('DATE(created_at)')
        .select('DATE(created_at) as date, COUNT(*) as total_count, ' \
                'SUM(CASE WHEN send_as_test THEN 1 ELSE 0 END) as test_count')
    end
  end

  # インスタンスメソッド
  def test_send?
    send_as_test
  end

  def formatted_phone_number
    return unless phone_number
    # 電話番号を整形（例：090-1234-5678）
    phone_number.gsub(/(\d{3})(\d{4})(\d{4})/, '\1-\2-\3')
  end

  def send_status
    test_send? ? 'テスト送信' : '本番送信'
  end

  private

  def validate_phone_number_format
    return if phone_number.blank?
    unless phone_number.match?(/\A\d{11}\z/)
      errors.add(:phone_number, 'は11桁の数字で入力してください')
    end
  end
end
