class SendListsController < ApplicationController
  before_action :set_send_list, only: [:show, :edit, :update, :destroy]

  def index
    @send_lists = SendList.all
  end

  def show
  end

  def new
    @send_list = SendList.new
  end

  def edit
  end

  def create
    @send_list = SendList.new(send_list_params)
    if @send_list.save
      redirect_to @send_list, notice: 'Send list was successfully created.'
    else
      render :new
    end
  end

  def update
    if @send_list.update(send_list_params)
      redirect_to @send_list, notice: 'Send list was successfully updated.'
    else
      render :edit
    end
  end

  def destroy
    @send_list.destroy
    redirect_to send_lists_url, notice: 'Send list was successfully destroyed.'
  end

  private
    def set_send_list
      @send_list = SendList.find(params[:id])
    end

    def send_list_params
      params.require(:send_list).permit(:item_id, :phone_number, :send_at, :sender_name, :user_id)
    end
end
