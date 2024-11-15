class UserSessionsController < ApplicationController
  skip_before_action :require_login, only: %i[create new]
  before_action :redirect_if_logged_in, only: %i[new create]

  def new; end

  def create
    @user = login(params[:email], params[:password])
    if @user
      @user.increment_login_count!
      after_login_redirect
    else
      flash.now[:danger] = 'ログインに失敗しました'
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    # ログアウト前に現在のユーザーのroleを保存しておく（必要に応じて）
    was_admin = current_user&.admin?
    logout
    redirect_to root_path, notice: "ログアウトしました"
  end

  private

  def redirect_if_logged_in
    if logged_in?
      redirect_path = current_user.admin? ? admin_top_path : root_path
      redirect_to redirect_path, info: "すでにログインしています"
    end
  end

  def after_login_redirect
    if @user.admin?
      redirect_to admin_top_path, success: "管理者としてログインしました"
    else
      redirect_back_or_to root_path, success: "ログインしました"
    end
  end
end
