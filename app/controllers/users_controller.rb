class UsersController < ApplicationController
  before_action :require_login, except: [:new, :create]
  before_action :set_user, only: [:show, :edit, :update, :edit_password, :update_password]

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    if @user.save
      redirect_to root_path, flash: { success: "ユーザー登録が成功しました" }
    else
      flash.now[:danger] = "ユーザー登録に失敗しました"
      render :new, status: :unprocessable_entity
    end
  end

  def show; end

  def edit; end

  def update
    if @user.update(user_params)
      redirect_to user_path(@user), flash: { success: "更新しました" }
    else
      flash.now[:danger] = "更新に失敗しました"
      render :edit, status: :unprocessable_entity
    end
  end

  def edit_password
    # 特に処理はなし
  end

  def update_password
    if @user.update(user_password_params)
      redirect_to @user, flash: { success: 'パスワードが更新されました。' }
    else
      render :edit_password
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

  def user_password_params
    params.require(:user).permit(:password, :password_confirmation)
  end

  def set_user
    @user = User.find(params[:id])
  end
end
