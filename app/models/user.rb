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

  enum :role, { admin: 0, general: 1, demo: 2 }

  # sorcery関連のメソッド
  def deliver_reset_password_instructions!
    return false if reset_password_email_sent_at && 
                    reset_password_email_sent_at > 5.minutes.ago

    if generate_reset_password_token!
      UserMailer.reset_password_email(self).deliver_later
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

  # パスワード関連のメソッド
  def change_password(new_password)
    self.password = new_password
    self.password_confirmation = new_password
    save(validate: true)
  end

  def update_password(new_password)
    self.password = new_password
    self.password_confirmation = new_password
    save
  end

  # ログイン関連のメソッド
  def increment_login_count!
    increment!(:login_count)
  end

  def first_login?
    login_count == 1
  end

  # 権限チェックメソッド
  def can_modify_items?
    !demo?
  end

  def can_view_all_items?
    admin? || demo?
  end


  def was_demo?
    # role_updated_atカラムがある場合
    return false if role_updated_at.nil?
    
    # 過去にroleが[demo: 2]だった記録があるかどうかを確認
    SendList.where(user: self, role_at_time: 2).exists?
  end

  private

  def ensure_uuid
    self.uuid ||= SecureRandom.uuid
  end

  def set_role_updated_at
    self.role_updated_at = Time.current
  end
end