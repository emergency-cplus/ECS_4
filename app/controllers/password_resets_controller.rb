class PasswordResetsController < ApplicationController
  skip_before_action :require_login

  def new; end

  def edit
    @token = params[:token]
    @user = User.load_from_reset_password_token(@token)
    
    unless @user
      Rails.logger.info("Invalid or expired password reset token")
      redirect_to new_password_reset_path, alert: '無効または期限切れのトークンです。もう一度試してください。'
    end
  end

  def create
    @user = User.find_by(email: params[:email])
    if @user
      @user.deliver_reset_password_instructions! # トークン生成と保存、メール送信
      redirect_to login_path, notice: 'パスワードリセットのメールを送信しました。メールをご確認ください。'
    else
      redirect_to new_password_reset_path, alert: '指定されたメールアドレスは見つかりませんでした。'
    end
  end

  def update
    @token = params[:token]
    @user = User.load_from_reset_password_token(@token)
  
    if @user.blank?
      redirect_to new_password_reset_path, alert: '無効または期限切れのトークンです。もう一度試してください。'
      return
    end
  
    @user.password_confirmation = params[:user][:password_confirmation]
    if @user.change_password(params[:user][:password])
      @user.clear_reset_password_token!
      redirect_to login_path, notice: 'パスワードがリセットされました。'
    else
      Rails.logger.error "パスワードの変更に失敗しました。エラー: #{@user.errors.full_messages}"
      flash.now[:alert] = 'パスワードリセットに失敗しました。もう一度試してください。'
      render :edit
    end
  end

  private

  # パスワードバリデーションをチェックするメソッド
  def valid_password_params?(password, confirmation)
    password == confirmation && password.length >= 6 && password.match?(/\A(?=.*[a-z])(?=.*[A-Z])(?=.*\d).+\z/)
  end
end
