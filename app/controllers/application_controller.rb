class ApplicationController < ActionController::Base
    before_action :require_login
    add_flash_types :success, :danger
    before_action :set_locale

    def set_locale
        I18n.locale = params[:locale] || I18n.default_locale
    end
    
    private

    def not_authenticated
        redirect_to login_path, danger: "ログインしてください"
    end
end
