class UserMailer < ApplicationMailer
  # メールアドレスは環境変数から取得する
  default from: ENV['RESET_PASSWORD_EMAIL'] || 'default-email@example.com'

  # パスワードリセットのメールを送信するメソッド
  def password_reset_email(user)
    @user = user
    @token = user.reset_password_token # Sorceryで生成されるトークン
    mail(to: @user.email, subject: 'パスワードリセット')
  end
end
