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
    if params[:phone_number].length != 11 || params[:phone_number].scan(/\D/).any?
      # 電話番号が11桁でない、または数字以外の文字が含まれている場合
      flash[:danger] = '入力に誤りがあります。電話番号はハイフンなしの11桁の数字を入力してください。'
      redirect_to items_path and return
    end

    sms_sender = SmsSender.new
    item = Item.find(params[:item_id])
    user_message = User.find(item.user_id).message_template
    full_body = "#{user_message} Check this out: #{item.item_url}"

    response = sms_sender.send_sms(
      to: params[:phone_number],
      body: full_body
    )

    if response.status == 'queued'
      SendList.create(
        phone_number: params[:phone_number],
        send_at: Time.zone.now,
        sender: params[:sender_name],
        item_id: item.id,
        user_id: current_user.id
      )
      redirect_to send_lists_path, notice: 'SMSを送信しました。'
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
