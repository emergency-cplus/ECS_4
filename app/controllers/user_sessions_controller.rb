class UserSessionsController < ApplicationController
  skip_before_action :require_login, only: %i[create new]
  before_action :redirect_if_logged_in, only: %i[new create]

  def new; end

  def create
    @user = login(params[:email], params[:password])
    if @user
      @user.increment_login_count!
      redirect_back_or_to root_path, success: "ログインしました"
    else
      flash.now[:danger] = 'ログインに失敗しました'
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    logout
    redirect_to root_path, success: "ログアウトしました"
  end

  private

  def redirect_if_logged_in
    redirect_to root_path, info: "すでにログインしています" if logged_in?
  end
end
