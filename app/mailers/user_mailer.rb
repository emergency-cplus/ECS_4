class UserMailer < ApplicationMailer
  default from: ENV['RESET_PASSWORD_EMAIL'] || 'default-email@example.com'

  def reset_password_email(user)
    @user = user
    @token = user.reset_password_token
    @url = edit_password_reset_url(@token)

    mail(
      to: @user.email,
      subject: 'パスワードリセットの手順'
    )
  end

  def welcome_email(user, password)
    @user = user
    @password = password

    mail(
      to: @user.email,
      subject: 'アカウント作成のお知らせ'
    )
  end
end
