class StaticPagesController < ApplicationController
  skip_before_action :require_login, only: %i[top privacy_policy terms_of_use]

  def top; end
  
  def privacy_policy; end

  def terms_of_use; end

  def not_found
    render file: "#{Rails.root}/public/404.html", status: :not_found
  end
  
end
