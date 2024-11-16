class User < ApplicationRecord
  authenticates_with_sorcery! do |config|
    config.load_plugin(:reset_password, { mailer: UserMailer, email_method_name: :reset_password_email })
  end

  has_many :items
  has_many :send_lists  # 追加

  validates :password, length: { minimum: 8 }, if: -> { new_record? || changes[:crypted_password] }
  validates :password, password_symbols: true, if: -> { new_record? || changes[:crypted_password] }
  validates :password, confirmation: true, if: -> { new_record? || changes[:crypted_password] }
  validates :password_confirmation, presence: true, if: -> { new_record? || changes[:crypted_password] }

  validates :email, uniqueness: true, presence: true
  validates :name, presence: true, length: { maximum: 255 }

  before_create :ensure_uuid

  # データベースレベルでroleのnullを制限、バリデーションは不要
  enum :role, { admin: 0, general: 1, demo: 2 }

  # sorceryで使う
  def deliver_reset_password_instructions!
    return false if reset_password_email_sent_at && 
                    reset_password_email_sent_at > 5.minutes.ago

    if generate_reset_password_token!
      UserMailer.reset_password_email(self).deliver_later  # deliver_now から変更
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
    save(validate: true)  # バリデーションは実行するが、変更の有無は確認しない
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

  private

  def ensure_uuid
    self.uuid ||= SecureRandom.uuid
  end
end
