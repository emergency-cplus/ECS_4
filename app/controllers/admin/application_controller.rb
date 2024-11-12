# app/controllers/admin/application_controller.rb
class Admin::ApplicationController < ApplicationController
    before_action :require_admin
  
    private
  
    def require_admin
      unless current_user&.admin?
        flash[:alert] = "管理者権限が必要です。"
        redirect_to root_path
      end
    end
  end
  