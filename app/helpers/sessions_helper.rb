module SessionsHelper
  def logged_in?
    !current_user.nil?
  end

  def redirect_if_logged_in
    if logged_in?
      redirect_to root_path, notice: 'すでにログインしています。'
    end
  end
end
