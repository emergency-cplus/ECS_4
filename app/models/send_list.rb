class SendList < ApplicationRecord
  belongs_to :item
  belongs_to :user

  validates :phone_number, presence: true
  validates :sender, presence: true

  scope :test_sends, -> { where(send_as_test: true) }
  scope :actual_sends, -> { where(send_as_test: false) }
  
  # 特定ユーザーの送信回数を取得
  def self.count_for_user(user_id, include_test: true)
    scope = where(user_id: user_id)
    scope = scope.actual_sends unless include_test
    scope.count
  end

  # 期間指定での送信回数取得
  def self.count_for_period(user_id, start_date, end_date, include_test: true)
    scope = where(user_id: user_id)
            .where(created_at: start_date.beginning_of_day..end_date.end_of_day)
    scope = scope.actual_sends unless include_test
    scope.count
  end
