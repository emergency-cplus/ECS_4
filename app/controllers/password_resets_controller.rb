class PasswordResetsController < ApplicationController
  skip_before_action :require_login

  def new; end

  def edit
    @token = params[:token]
    @user = User.load_from_reset_password_token(@token)

    if @user.blank?
      not_authenticated
      nil
    end
  end

  def create
    @user = User.find_by(email: params[:email])
    
    # ユーザーの存在有無に関わらず、同じメッセージを表示
    flash[:notice] = "パスワードリセットの手順を記載したメールを送信しました。メールが届かない場合は、入力したアドレスをご確認ください。"
    
    if @user
      @user.deliver_reset_password_instructions!
    else
      # ユーザーが存在しない場合、同等の処理時間を確保
      BCrypt::Password.create(SecureRandom.hex(10))
    end
    
    redirect_to login_path
  end

  def update
    @token = params[:token] # params[:id] ではなく params[:token] から取得
    @user = User.load_from_reset_password_token(@token)

    if @user.blank?
      not_authenticated
      return
    end

    @user.password_confirmation = params[:user][:password_confirmation]
    if @user.change_password(params[:user][:password])
      @user.clear_reset_password_token!
      flash.keep[:success] = 'パスワードを変更しました。新しいパスワードでログインしてください。'
      redirect_to login_path
    else
      flash.now[:alert] = 'パスワードの変更に失敗しました。'
      render :edit
    end
  end

  private

  def not_authenticated
    if controller_name == 'password_resets' && action_name == 'edit'
      redirect_to new_password_reset_path, 
                  alert: '無効または期限切れのトークンです。もう一度パスワードリセットを申請してください。'
    elsif controller_name == 'password_resets' && action_name == 'update'
      flash.keep[:success] = 'パスワードを変更しました。新しいパスワードでログインしてください。'
      redirect_to login_path
    # notice: 'パスワードが正常に更新されました。新しいパスワードでログインしてください。'
    else
      redirect_to login_path, notice: "ログインしてください"
    end
  end
end
