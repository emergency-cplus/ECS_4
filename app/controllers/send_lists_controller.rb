class SendListsController < ApplicationController
  before_action :set_send_list, only: [:show, :edit, :update]

  def index
    @send_lists = SendList.all
  end

  def show; end

  def new
    @send_list = SendList.new
  end

  def edit; end

  def create
  sms_sender = SmsSender.new
  item = Item.find(params[:item_id])

  response = sms_sender.send_sms(
    to: params[:phone_number],
    body: "#{User.find(item.user_id).message_template} Check this out: #{item.item_url}",
    item: item
  )

  if response.status == 'queued'
    SendList.create(
      phone_number: params[:phone_number],
      send_at: Time.zone.now,
      sender: params[:sender_name],
      item_id: item.id,
      user_id: current_user.id
    )
    redirect_to send_lists_path, success: 'SMSを送信しました。'
  else
    redirect_to send_lists_path, alert: 'SMSの送信に失敗しました。'
  end
end

  def update; end

  private
    def set_send_list
      @send_list = SendList.find(params[:id])
    end

    def send_list_params
      params.require(:send_list).permit(:phone_number, :sender_name, :item_id, :user_id, :send_at)
    end
end
