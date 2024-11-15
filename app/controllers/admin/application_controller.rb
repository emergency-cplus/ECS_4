# app/controllers/admin/application_controller.rb
class Admin::ApplicationController < ApplicationController
  before_action :require_admin
  # layout 'admin'  # 管理画面用のレイアウトを使用する場合

end
