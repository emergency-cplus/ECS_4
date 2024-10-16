class User < ApplicationRecord
  authenticates_with_sorcery! do |config|
    config.load_plugin(:reset_password, { mailer: UserMailer, email_method_name: :reset_password_email })
  end

  has_many :items

  validates :password, length: { minimum: 8 }, if: -> { new_record? || changes[:crypted_password] }
  validates :password, password_symbols: true, if: -> { new_record? || changes[:crypted_password] }
  validates :password, confirmation: true, if: -> { new_record? || changes[:crypted_password] }
  validates :password_confirmation, presence: true, if: -> { new_record? || changes[:crypted_password] }

  validates :email, uniqueness: true, presence: true
  validates :name, presence: true, length: { maximum: 255 }

  before_create :ensure_uuid

  enum role: { guest: 0, general: 1, admin: 2 }

  # sorceryで使う
  def deliver_reset_password_instructions!
    generate_reset_password_token!
    UserMailer.reset_password_email(self).deliver_now
  end

  def clear_reset_password_token!
    update_columns(
      reset_password_token: nil,
      reset_password_token_expires_at: nil
    )
  end

  def change_password(new_password)
    self.password = new_password
    if valid?
      save
    else
      errors.add(:password, 'は最低8文字で、数字と大文字を含む必要があります。')
      false
    end
  end

  private

  def ensure_uuid
    self.uuid ||= SecureRandom.uuid
  end
end
