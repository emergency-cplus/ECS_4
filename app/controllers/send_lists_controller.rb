class SendListsController < ApplicationController
  before_action :set_send_list, only: [:show, :edit, :update]

  def index
    @send_lists = SendList.includes(:item)  # N+1クエリ対策
                         .order(created_at: :desc)
                         .page(params[:page])
                         .per(20)
  end

  def show; end

  def new
    @send_list = SendList.new
  end

  def edit; end

  def create
    @send_list = SendList.new(send_list_params)
    @send_list.user = current_user
    @send_list.send_at = Time.current

    unless @send_list.valid?
      flash[:alert] = @send_list.errors.full_messages.join(', ')
      redirect_to send_lists_path and return
    end

    begin
      item = Item.find(@send_list.item_id)
      sms_sender = SmsSender.new
      
      response = sms_sender.send_sms(
        to: @send_list.phone_number,
        body: '',
        item: item,
        is_test: params[:send_as_test].present?
      )

      if response&.status == 'queued'
        @send_list.save!
        flash[:notice] = @send_list.send_as_test ? 'テストSMSを送信しました' : 'SMSを送信しました'
      else
        flash[:alert] = 'SMSの送信に失敗しました'
      end

    rescue ActiveRecord::RecordNotFound
      flash[:alert] = 'アイテムが見つかりませんでした'
    rescue Twilio::REST::TwilioError => e
      flash[:alert] = "SMS送信エラー: #{e.message}"
      Rails.logger.error "Twilioエラー: #{e.message}"
    rescue StandardError => e
      flash[:alert] = 'エラーが発生しました'
      Rails.logger.error "予期せぬエラー: #{e.class} - #{e.message}"
      Rails.logger.error e.backtrace.join("\n")
    end

    redirect_to send_lists_path
  end

  def update; end

  def check_send_limit
    if current_user.demo? && current_user.todays_send_count >= User::DEMO_DAILY_LIMIT
      next_reset = Time.current.beginning_of_day + User::RESET_HOUR.hours + User::RESET_MINUTE.minutes
      next_reset += 1.day if Time.current >= next_reset
      
      flash[:alert] = "1日の送信可能回数（#{User::DEMO_DAILY_LIMIT}回）を超えました。"
      redirect_to send_lists_path and return
    end
  end

  private

  def set_send_list
    @send_list = SendList.find(params[:id])
  end

  def send_list_params
    params.permit(:phone_number, :sender, :item_id, :send_at, :send_as_test)
  end
  
end
