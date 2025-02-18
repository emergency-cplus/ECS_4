class SendList < ApplicationRecord
  belongs_to :item
  belongs_to :user

  # demoの送信数制限はデフォルトで5回まで（admin, generalの場合は送信数制限なし）
  # 送信数のカウントは始業時間（AM8:30~翌AM8:30）を基準にリセット
  DEMO_DAILY_LIMIT = 5
  RESET_HOUR = 8
  RESET_MINUTE = 30

  # roleの定義をUserモデルから参照
  enum :role_at_time, User.roles

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

  scope :viewable_for_admin, -> { all } # adminは全て見れる
  scope :viewable_for_general, lambda { |user_id| 
    user = User.find(user_id)
    where(user_id: user.id).or(where(user_id: user.id, role_at_time: User.roles[:demo])) 
  }
  scope :viewable_for_demo, -> { where(role_at_time: User.roles[:demo]) }

  # コールバックを追加して、作成時にユーザーのroleを保存
  before_create :set_role_at_time

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
  end

  private

  def check_demo_user_limit
    return unless user&.demo?
    return unless todays_send_count >= DEMO_DAILY_LIMIT

    errors.add(:base, "デモユーザーの1日の送信制限（#{DEMO_DAILY_LIMIT}回）を超えています")
  end

  def set_role_at_time
    self.role_at_time = user.role
  end
end
