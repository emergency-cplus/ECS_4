class SendList < ApplicationRecord
  belongs_to :item
  belongs_to :user

  # demoの送信数制限はデフォルトで5回まで（admin, generalの場合は送信数制限なし）
  # 送信数のカウントは始業時間（AM8:30~翌AM8:30）を基準にリセット
  DEMO_DAILY_LIMIT = 5
  RESET_HOUR = 8
  RESET_MINUTE = 30

  # バリデーション
  validates :phone_number, presence: true,
                           format: { with: /\A\d{11}\z/, message: 'は11桁の数字で入力してください' }
  validates :sender, presence: true
  validates :send_at, presence: true
  validate :check_demo_user_limit, on: :create

  # スコープ
  scope :test_sends, -> { where(send_as_test: true) }
  scope :actual_sends, -> { where(send_as_test: false) }
  scope :in_period, lambda { |start_date, end_date| 
    where(created_at: start_date.beginning_of_day..end_date.end_of_day) 
  }
  scope :for_user, ->(user_id) { where(user_id:) }

  # SMS送信制限関連メソッド
  def todays_send_count
    last_reset = Time.current.beginning_of_day + RESET_HOUR.hours + RESET_MINUTE.minutes
    next_reset = last_reset + 1.day

    if Time.current < last_reset
      last_reset -= 1.day
      next_reset -= 1.day
    end

    self.class.where(user_id:, created_at: last_reset..next_reset).count
  end

  def todays_send_limit
    user.demo? ? DEMO_DAILY_LIMIT : Float::INFINITY
  end

  # 既存のインスタンスメソッド
  def test_send?
    send_as_test
  end

  def formatted_phone_number
    return unless phone_number

    phone_number.gsub(/(\d{3})(\d{4})(\d{4})/, '\1-\2-\3')
  end

  def send_status
    test_send? ? 'テスト送信' : '本番送信'
  end

  # クラスメソッド（ダッシュボードで活用、月の）
  class << self
    # 各ユーザーの総SMS送信数を取得
    def count_for_user(user_id, include_test: true)
      scope = for_user(user_id)
      scope = scope.actual_sends unless include_test
      scope.count
    end

    # 期間を指定してユーザーの送信数を取得
    # def count_for_period(user_id, start_date, end_date, include_test: true)
    #   scope = for_user(user_id).in_period(start_date, end_date)
    #   scope = scope.actual_sends unless include_test
    #   scope.count
    # end

    # 日別の利用状況レポート
    # def daily_stats(user_id, days = 30)
    #   start_date = days.days.ago.beginning_of_day
    #   for_user(user_id)
    #     .where('created_at >= ?', start_date)
    #     .group('DATE(created_at)')
    #     .select('DATE(created_at) as date, COUNT(*) as total_count, ' \
    #             'SUM(CASE WHEN send_as_test THEN 1 ELSE 0 END) as test_count')
    # end
  end

  private

  def check_demo_user_limit
    return unless user&.demo?

    return unless todays_send_count >= DEMO_DAILY_LIMIT

    errors.add(:base, "デモユーザーの1日の送信制限（#{DEMO_DAILY_LIMIT}回）を超えています")
    
  end
end
