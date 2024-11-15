# app/controllers/admin/base_controller.rb
class Admin::DashboardsController < Admin::ApplicationController
  before_action :require_admin

  private

  def require_admin
    unless current_user&.admin?
      flash[:alert] = '権限がありません'
      redirect_to root_path
    end
  end
end
