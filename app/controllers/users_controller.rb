class UsersController < ApplicationController
  before_action :require_login, except: [:new, :create]
  before_action :require_admin, only: [:index, :new, :create, :destroy]
  before_action :set_user, only: [:show, :edit, :update, :edit_password, :update_password]
  before_action :correct_user, only: [:show, :edit, :update, :edit_password, :update_password]

  def index
    @users = User.all
  end

  def show; end # @user は set_user で設定済み

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

  # def update_password
  #   if params[:user][:password] != params[:user][:password_confirmation]
  #     redirect_to edit_password_user_path(@user.uuid), flash: { danger: '入力されたパスワードが一致しません。' }
  #     return
  #   end
  
  #   if same_as_old_password?(@user, params[:user][:password])
  #     redirect_to edit_password_user_path(@user.uuid), flash: { danger: '新しいパスワードが以前のパスワードと同じです。' }
  #     return
  #   end
  
  #   if @user.update(user_password_params)
  #     logout # ログアウトメソッドを呼び出し、セッションをクリアする
  #     flash[:success] = 'パスワードが更新されました。再ログインしてください。'
  #     redirect_to login_path # ログインページにリダイレクト
  #   else
  #     redirect_to edit_password_user_path(@user.uuid), flash: { danger: @user.errors.full_messages.join + " 許可された記号: !@#$%^&*()_+-" }
  #   end
  # end

  def update_password
    # パスワードの一致確認
    if params[:user][:password] != params[:user][:password_confirmation]
      flash.now[:danger] = '入力されたパスワードが一致しません。'
      render :edit_password, status: :unprocessable_entity
      return
    end
  
    # 初回ログイン以外の場合のみ、既存パスワードとの比較を行う
    unless @user.login_count.zero?
      if same_as_old_password?(@user, params[:user][:password])
        flash.now[:danger] = '新しいパスワードが以前のパスワードと同じです。'
        render :edit_password, status: :unprocessable_entity
        return
      end
    end
  
    @user.assign_attributes(user_password_params)
    
    if @user.save
      # 初回ログイン時のみログインカウントを1に設定
      if @user.login_count.zero?
        @user.update_column(:login_count, 1)
      end
  
      # セッションをクリアしてログアウト
      logout
      
      # 成功メッセージを設定してログインページへリダイレクト
      flash[:success] = 'パスワードが更新されました。再ログインしてください。'
      redirect_to login_path
    else
      # バリデーションエラー時の処理
      flash.now[:danger] = "#{@user.errors.full_messages.join(' ')} 許可された記号: !@#$%^&*()_+-"
      render :edit_password, status: :unprocessable_entity
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

  def require_login
    unless logged_in?
      flash[:danger] = "ログインしてください"
      redirect_to login_url, status: :see_other
    end
  end

  def user_params
    params.require(:user).permit(:name, :email, :message_template)
  end

  def admin_user_params
    params.require(:user).permit(:name, :email, :password, :password_confirmation, :message_template, :role)
  end

  def correct_user
    redirect_to(root_url) unless current_user.admin? || current_user == @user
  end

  def set_user
    @user = User.find_by(uuid: params[:uuid])
    if @user.nil?
      redirect_to root_url, alert: "ユーザーが見つかりませんでした。"
    end
  end

  def user_password_params
    params.require(:user).permit(:password, :password_confirmation)
  end

  def same_as_old_password?(user, new_password)
    user.crypted_password.present? && Sorcery::CryptoProviders::BCrypt.matches?(user.crypted_password, new_password, user.salt)
  end

  def require_admin
    redirect_to root_path, alert: '管理者権限が必要です。' unless current_user&.admin?
  end
end
