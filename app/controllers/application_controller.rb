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

def enforce_password_change_on_first_login
  return if current_user.admin? # 管理者はスキップ
  return if current_user.login_count > 0 # パスワード変更済みならスキップ
  # パスワード変更関連のアクションの場合はスキップ
  return if controller_name == 'users' && ['edit_password', 'update_password'].include?(action_name)
  
  flash[:warning] = '初回ログインです。セキュリティのため、パスワードを変更してください'
  redirect_to edit_password_user_path(uuid: current_user.uuid)
end

end