module Admin
  class ApplicationController < ApplicationController
    before_action :require_admin
    # layout 'admin'

    private

    def require_admin
      return if current_user&.admin?

      flash[:error] = '管理者権限が必要です'
      redirect_to root_path
      
    end
  end
end
