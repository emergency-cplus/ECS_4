class UsersController < ApplicationController
  before_action :require_login, except: [:new, :create]
  before_action :set_user, only: [:show, :edit, :update, :edit_password, :update_password]
  before_action :correct_user, only: [:show]

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    if @user.save
      auto_login(@user)  # ユーザーを自動的にログインさせる
      redirect_to root_path, flash: { success: "ユーザー登録が成功し、ログインしました" }
    else
      flash.now[:danger] = "ユーザー登録に失敗しました"
      render :new, status: :unprocessable_entity
    end
  end

  def show
    # @user = User.find_by(uuid: params[:id])
  end

  def edit; end

  def update
    if @user.update(user_params)
      redirect_to user_path(uuid: @user.uuid), flash: { success: "更新しました" }
    else
      flash.now[:danger] = "更新に失敗しました"
      render :edit, status: :unprocessable_entity
    end
  end  

  def edit_password; end

  def update_password
    if params[:user][:password] != params[:user][:password_confirmation]
      redirect_to edit_password_user_path(@user.uuid), flash: { danger: '入力されたパスワードが一致しません。' }
      return
    end
  
    if same_as_old_password?(@user, params[:user][:password])
      redirect_to edit_password_user_path(@user.uuid), flash: { danger: '新しいパスワードが以前のパスワードと同じです。' }
      return
    end
  
    if @user.update(user_password_params)
      logout # ログアウトメソッドを呼び出し、セッションをクリアする
      flash[:success] = 'パスワードが更新されました。再ログインしてください。'
      redirect_to login_path # ログインページにリダイレクト
    else
      redirect_to edit_password_user_path(@user.uuid), flash: { danger: @user.errors.full_messages.join + " 許可された記号: !@#$%^&*()_+-" }
    end
  end

  private

  def require_login
    unless logged_in?
      flash[:danger] = "ログインしてください"
      redirect_to login_url, status: :see_other
    end
  end

  def user_params
    params.require(:user).permit(:name, :email, :password, :password_confirmation, :message_template)
  end

  def correct_user
    redirect_to(root_url) unless current_user == @user
  end

  def set_user
    Rails.logger.debug "Requested UUID: #{params[:uuid]}"
    @user = User.find_by(uuid: params[:uuid])
    if @user.nil?
      Rails.logger.debug "No user found with UUID: #{params[:uuid]}"
      redirect_to root_url, alert: "ユーザーが見つかりませんでした。"
    end
  end

  def user_password_params
    params.require(:user).permit(:password, :password_confirmation)
  end

  def same_as_old_password?(user, new_password)
    user.crypted_password.present? && Sorcery::CryptoProviders::BCrypt.matches?(user.crypted_password, new_password, user.salt)
  end
end
