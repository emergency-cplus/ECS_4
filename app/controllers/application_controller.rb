class ApplicationController < ActionController::Base
  before_action :require_login

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
end
