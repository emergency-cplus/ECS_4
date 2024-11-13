Rails.application.config.sorcery.submodules = [:reset_password, :test_helpers]  # リセットパスワードモジュールを有効化

Rails.application.config.sorcery.configure do |config|
  config.user_config do |user|
    # パスワードリセットメーラーとメールメソッド名の設定
    user.reset_password_mailer = UserMailer
    user.reset_password_email_method_name = :reset_password_email

    # パスワードリセットの有効期限とメール送信間隔
    user.reset_password_expiration_period = 15.minutes
    user.reset_password_time_between_emails = 1.minute
  end

  # ユーザークラスの指定
  config.user_class = "User"
end
