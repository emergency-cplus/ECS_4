class ApplicationController < ActionController::Base
  before_action :require_login
  before_action :enforce_password_change_on_first_login, if: :logged_in?

  private

  def not_authenticated
    flash[:warning] = 'ログインしてください'
    redirect_to login_path
  end

  def check_admin_redirect
    return if current_user&.admin?

    flash[:alert] = '権限がありません'
    redirect_to root_path
  end

  # ユーザーに初回ログイン時のパスワード変更を強制する
  def enforce_password_change_on_first_login
    if current_user.login_count == 1 && !current_user.admin?
      flash[:warning] = '初回ログインです。セキュリティのため、パスワードを変更してください'
      redirect_to edit_password_user_path(current_user) 
    end
  end
end