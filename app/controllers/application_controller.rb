# app/controllers/application_controller.rb
class ApplicationController < ActionController::Base
  include SessionsHelper
  before_action :require_login
  add_flash_types :success, :danger
  before_action :set_locale
  before_action :check_password_change, if: :logged_in?

  private

  def set_locale
    I18n.locale = params[:locale] || I18n.default_locale
  end

  def require_admin
    redirect_to root_path, alert: '管理者権限が必要です。' unless current_user&.admin?
  end

  def not_authenticated
    redirect_to login_path, notice: "ログインしてください"
  end

  def check_password_change
    if current_user.login_count == 1 && !current_user.admin?
      redirect_to edit_password_user_path(current_user), 
        danger: '初回ログインです。セキュリティのため、パスワードを変更してください'
    end
  end

  def require_login
    unless logged_in?
      flash[:danger] = "ログインしてください"
      redirect_to login_url, status: :see_other
    end
  end

  def correct_user
    redirect_to(root_url) unless current_user.admin? || current_user == @user
  end
end
