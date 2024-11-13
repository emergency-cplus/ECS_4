class UserMailer < ApplicationMailer
  # メールアドレスは環境変数から取得する
  default from: ENV['RESET_PASSWORD_EMAIL'] || 'default-email@example.com'

  # パスワードリセットのメールを送信するメソッド
  def reset_password_email(user)
    @user = user
    @token = user.reset_password_token
    @url = edit_password_reset_url(@token)  # URLヘルパーを使用

    mail(
      to: @user.email,
      subject: 'パスワードリセットの手順',
      content_type: "text/html"
    )
  end
end
