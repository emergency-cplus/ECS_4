class PasswordResetsController < ApplicationController
  skip_before_action :require_login

  def new; end

  def edit
    @token = params[:id]
    @user = User.load_from_reset_password_token(@token)
    unless @user
      redirect_to new_password_reset_path, alert: '無効または期限切れのトークンです。もう一度試してください。'
    end
  end

  def create
    @user = User.find_by(email: params[:email])
    @user&.deliver_reset_password_instructions!
    redirect_to login_path, notice: 'パスワードリセットのメールを送信しました。メールをご確認ください。'
  end

  def update
    @token = params[:id]
    @user = User.load_from_reset_password_token(@token)

    if @user.blank?
      redirect_to new_password_reset_path, alert: '無効または期限切れのトークンです。もう一度試してください。'
      return
    end

    if valid_password_params?(params[:user][:password], params[:user][:password_confirmation])
      if @user.change_password(params[:user][:password])
        redirect_to login_path, notice: 'パスワードがリセットされました。新しいパスワードでログインしてください。'
      else
        flash.now[:error] = 'パスワードリセットに失敗しました。もう一度試してください。'
        render :edit
      end
    else
      flash.now[:error] = 'パスワードは最低6文字で、数字と大文字を含む必要があります。'
      render :edit
    end
  end

  private

  # パスワードバリデーションをチェックするメソッド
  def valid_password_params?(password, confirmation)
    password == confirmation && password.length >= 6 && password.match?(/\A(?=.*[a-z])(?=.*[A-Z])(?=.*\d).+\z/)
  end
end
