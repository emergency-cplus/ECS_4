class UsersController < ApplicationController
  before_action :require_login, except: [:new, :create]
  # before_action :set_user, only: [:show, :edit, :update]

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    
    if @user.save
      # あえてroot_pathにリダイレクトさせる
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

  # def edit_password
  #   @user = current_user # ここで適切に@userをセットする
  #   @user_password = UserPassword.new
  # end

  # def update_password
  #   @user_password = UserPassword.new(password_params)
  #   if @user_password.valid?
  #     if @user.update(password: @user_password.password, password_confirmation: @user_password.password_confirmation)
  #       redirect_to user_path(@user), flash: { success: t('users.update_password.success') }
  #     else
  #       flash.now[:danger] = t('users.update_password.failure')
  #       render :edit_password, status: :unprocessable_entity
  #     end
  #   else
  #     render :edit_password, status: :unprocessable_entity
  #   end
  # end

  private

  def require_login
    unless logged_in?
      flash[:error] = "ログインしてください"
      redirect_to login_url, status: :see_other
    end
  end

  def user_params
    params.require(:user).permit(:name, :email, :password, :password_confirmation)
  end

  # def password_params
  #   params.require(:user_password).permit(:password, :password_confirmation)
  # end

  def set_user
    @user = User.find(params[:id])
  end
end
