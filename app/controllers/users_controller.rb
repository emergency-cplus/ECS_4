class UsersController < ApplicationController
  before_action :require_login, except: [:new, :create]
  # before_action :require_admin, only: [:index, :new, :create, :destroy]
  before_action :set_user, only: [:show, :edit, :update, :edit_password, :update_password]
  before_action :correct_user, only: [:show, :edit, :update, :edit_password, :update_password]

  # def index # indexアクションを削除（管理者機能）
  #   @users = User.all
  # end

  def show; end

  def new
    @user = User.new
  end

  def edit; end

  def create
    @user = User.new(admin_user_params)
    if @user.save
      redirect_to users_path, flash: { success: "新しいユーザーを登録しました" }
    else
      flash.now[:danger] = "ユーザー登録に失敗しました"
      render :new, status: :unprocessable_entity
    end
  end

  def update
    update_params = current_user.admin? ? admin_user_params : user_params
    if @user.update(update_params)
      redirect_to user_path(uuid: @user.uuid), flash: { success: "更新しました" }
    else
      flash.now[:danger] = "更新に失敗しました"
      render :edit, status: :unprocessable_entity
    end
  end

  def edit_password; end

  def update_password
    if password_mismatch?
      handle_password_mismatch
    elsif !new_password_allowed?
      handle_invalid_new_password
    else
      process_password_update
    end
  end

  def destroy
    user = User.find_by(uuid: params[:uuid])
    if user&.destroy
      redirect_to users_path, flash: { success: "ユーザーを削除しました" }
    else
      redirect_to users_path, flash: { danger: "ユーザーの削除に失敗しました" }
    end
  end

  private

  def password_mismatch?
    params[:user][:password] != params[:user][:password_confirmation]
  end

  def handle_password_mismatch
    flash.now[:danger] = '入力されたパスワードが一致しません。'
    render :edit_password, status: :unprocessable_entity
  end

  def new_password_allowed?
    @user.login_count.zero? || !same_as_old_password?(@user, params[:user][:password])
  end

  def handle_invalid_new_password
    flash.now[:danger] = '新しいパスワードが以前のパスワードと同じです。'
    render :edit_password, status: :unprocessable_entity
  end

  def process_password_update
    @user.assign_attributes(user_password_params)
    
    if @user.save
      handle_successful_password_update
    else
      handle_failed_password_update
    end
  end

  def handle_successful_password_update
    @user.update_column(:login_count, 1) if @user.login_count.zero?
    logout
    flash[:success] = 'パスワードが更新されました。再ログインしてください。'
    redirect_to login_path
  end

  def handle_failed_password_update
    flash.now[:danger] = "#{@user.errors.full_messages.join(' ')} 許可された記号: !@#$%^&*()_+-"
    render :edit_password, status: :unprocessable_entity
  end

  def user_params
    params.require(:user).permit(:name, :email)
  end

  def admin_user_params
    params.require(:user).permit(:name, :email, :password, :password_confirmation, :role)
  end

  def set_user
    @user = User.find_by(uuid: params[:uuid])
    redirect_to root_url, alert: "ユーザーが見つかりませんでした。" if @user.nil?
  end

  def user_password_params
    params.require(:user).permit(:password, :password_confirmation)
  end

  def same_as_old_password?(user, new_password)
    user.crypted_password.present? && Sorcery::CryptoProviders::BCrypt.matches?(user.crypted_password, new_password, user.salt)
  end

  def correct_user
    # 管理者の場合は全てのユーザーにアクセス可能
    return if current_user.admin?
    
    # 一般ユーザーの場合は自分のページのみアクセス可能
    unless @user == current_user
      flash[:danger] = "アクセス権限がありません"
      redirect_to root_url
    end
  end
end
