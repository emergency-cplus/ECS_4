class User < ApplicationRecord
  authenticates_with_sorcery! do |config|
    config.load_plugin(:reset_password, { mailer: UserMailer, email_method_name: :reset_password_email })
  end

  has_many :items

  validates :password, length: { minimum: 3 }, if: -> { new_record? || changes[:crypted_password] }
  validates :password, confirmation: true, if: -> { new_record? || changes[:crypted_password] }
  validates :password_confirmation, presence: true, if: -> { new_record? || changes[:crypted_password] }
  validates :reset_password_token, uniqueness: true, allow_nil: true

  validates :email, uniqueness: true, presence: true
  validates :name, presence: true, length: { maximum: 255 }

  # UUIDを生成して確保する
  before_create :ensure_uuid

  # パスワードリセットトークンを生成し、メールを送信するメソッド
  # ※ このメソッドは、Sorceryのデフォルトのメール送信機能をオーバーライドしています
  def send_password_reset_email
    self.reset_password_token = SecureRandom.urlsafe_base64
    self.reset_password_sent_at = Time.zone.now
    save!(validate: false)
    UserMailer.reset_password_email(self).deliver_now
  end

  private

  def ensure_uuid
    self.uuid ||= SecureRandom.uuid
  end
end
