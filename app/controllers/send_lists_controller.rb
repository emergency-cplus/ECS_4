class SendListsController < ApplicationController
  before_action :set_send_list, only: [:show, :edit, :update]

  def index
    @send_lists = SendList.order(created_at: :desc).page(params[:page]).per(20)
  end

  def show; end

  def new
    @send_list = SendList.new
  end

  def edit; end

  def create
    if params[:phone_number].length != 11 || params[:phone_number].scan(/\D/).any?
      flash[:danger] = '入力に誤りがあります。電話番号はハイフンなしの11桁の数字を入力してください。'
      redirect_to items_path and return
    end
  
    sms_sender = SmsSender.new
    item = Item.find(params[:item_id])
    user_message = User.find(item.user_id).message_template
    full_body = "#{user_message} Check this out: #{item.item_url}"
  
    begin
      response = sms_sender.send_sms(
        to: params[:phone_number],
        body: full_body,
        item: item  # ここで item 引数を渡します
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
        redirect_to send_lists_path, danger: 'SMSの送信に失敗しました。'
      end
    rescue StandardError => e
      logger.error "SMS sending failed: #{e.message}"
      redirect_to send_lists_path, danger: 'SMS送信中にエラーが発生しました。'
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
