class UserMailer < ApplicationMailer
  default from: 'your-email@example.com'

  # パスワードリセットのメールを送信するメソッド
  def password_reset_email(user)
    @user = user
    @token = user.reset_password_token # Sorceryで生成されるトークン
    mail(to: @user.email, subject: 'パスワードリセットの指示')
  end
end
