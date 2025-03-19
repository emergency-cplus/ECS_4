module Admin
  class UsersController < ApplicationController
    before_action :require_login
    before_action :require_admin
    before_action :set_user, only: [:edit, :update, :destroy]

    def index
      @users = User.page(params[:page]).per(10)
    end

    def new
      @user = User.new
    end

    def edit
      # @user = User.find(params[:id])
    end

    def create
      # @user = User.new(user_params)
      temp_password = generate_simple_secure_password
      @user.password = temp_password
      @user.password_confirmation = temp_password
      @user.login_count = 0 # 初回ログインフラグとして使用

      if @user.save
        # メールで仮パスワードを送信
        UserMailer.welcome_email(@user, temp_password).deliver_now
        redirect_to admin_users_path, notice: 'ユーザーを作成し、仮パスワードを送信しました'
      else
        render :new
      end
    end

    def update
      @user = User.find(params[:id])
      if @user.update(role_params)
        redirect_to admin_users_path, notice: 'ユーザーの権限を更新しました'
      else
        render :edit
      end
    end

    def destroy
      # 自分自身は削除できないようにする
      if @user == current_user
        redirect_to admin_users_path, alert: '自分自身を削除することはできません'
        return
      end
      
      # 最後の管理者は削除できないようにする
      if @user.role == 'admin' && User.where(role: 'admin').count <= 1
        redirect_to admin_users_path, alert: '最後の管理者は削除できません'
        return
      end
      
      # ユーザー削除処理
      if @user.destroy
        flash[:notice] = "ユーザー「#{@user.name}」を削除しました"
        redirect_to admin_users_path
      else
        flash[:alert] = "ユーザー「#{@user.name}」の削除に失敗しました"
        redirect_to admin_users_path
      end
    end

    private

    def user_params
      params.require(:user).permit(:name, :email, :role)
    end

    def set_user
      @user = User.find(params[:id])
    end

    def role_params
      params.require(:user).permit(:role)
    end

    def require_admin
      redirect_to root_path, alert: '管理者権限が必要です' unless current_user.admin?
    end
  
    def generate_simple_secure_password
      random_part = SecureRandom.alphanumeric(6)
      "A!#{random_part}"
    end
  end
end
