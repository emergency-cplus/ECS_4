class User < ApplicationRecord
  authenticates_with_sorcery! do |config|
    config.load_plugin(:reset_password, { mailer: UserMailer, email_method_name: :reset_password_email })
  end

  has_many :items
  has_many :send_lists

  validates :password, length: { minimum: 8 }, if: -> { new_record? || changes[:crypted_password] }
  validates :password, password_symbols: true, if: -> { new_record? || changes[:crypted_password] }
  validates :password, confirmation: true, if: -> { new_record? || changes[:crypted_password] }
  validates :password_confirmation, presence: true, if: -> { new_record? || changes[:crypted_password] }

  validates :email, uniqueness: true, presence: true
  validates :name, presence: true, length: { maximum: 255 }

  before_save :set_role_updated_at, if: :will_save_change_to_role?
  before_create :ensure_uuid

  # データベースレベルでroleのnullを制限、バリデーションは不要
  enum :role, { admin: 0, general: 1, demo: 2 }

  # demoの送信数制限はデフォルトで5回まで（admin, generalの場合は送信数制限なし）
  # 送信数のカウントは始業時間（AM8:30~翌AM8:30）を基準にリセット
  DEMO_DAILY_LIMIT = 5
  RESET_HOUR = 8
  RESET_MINUTE = 30

  # sorceryで使う
  def deliver_reset_password_instructions!
    return false if reset_password_email_sent_at && 
                    reset_password_email_sent_at > 5.minutes.ago

    if generate_reset_password_token!
      UserMailer.reset_password_email(self).deliver_later # deliver_now から変更
      update_column(:reset_password_email_sent_at, Time.current)
      true
    else
      false
    end
  end

  def clear_reset_password_token!
    update_columns(
      reset_password_token: nil,
      reset_password_token_expires_at: nil
    )
  end

  def change_password(new_password)
    self.password = new_password
    self.password_confirmation = new_password
    save(validate: true) # バリデーションは実行するが、変更の有無は確認しない
  end

  def increment_login_count!
    increment!(:login_count)
  end

  def first_login?
    login_count == 1
  end

  def update_password(new_password)
    self.password = new_password
    self.password_confirmation = new_password
    save
  end

  # デモユーザーの操作制限に関するメソッドを追加
  def can_modify_items?
    !demo?
  end

  def can_view_all_items?
    admin? || demo?
  end

  def todays_send_count
    last_reset = Time.current.beginning_of_day + RESET_HOUR.hours + RESET_MINUTE.minutes
    next_reset = last_reset + 1.day
    
    if Time.current < last_reset
      last_reset -= 1.day
      next_reset -= 1.day
    end

    send_lists.where(created_at: last_reset..next_reset).count
  end
  
  def todays_send_limit
    demo? ? DEMO_DAILY_LIMIT : Float::INFINITY
  end

  private

  def ensure_uuid
    self.uuid ||= SecureRandom.uuid
  end

  def set_role_updated_at
    self.role_updated_at = Time.current
  end
end
