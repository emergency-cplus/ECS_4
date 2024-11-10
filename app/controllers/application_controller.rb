class ApplicationController < ActionController::Base
  include SessionsHelper
  before_action :require_login
  add_flash_types :success, :danger
  before_action :set_locale
  before_action :check_password_change, if: :logged_in?

  def set_locale
      I18n.locale = params[:locale] || I18n.default_locale
  end
  
  private

  def not_authenticated
    redirect_to login_path, danger: "ログインしてください"
  end

  def check_password_change
    if current_user.login_count == 1 && !current_user.admin?
      redirect_to edit_user_password_path, 
        danger: '初回ログインです。セキュリティのため、パスワードを変更してください'
    end
  end
end
