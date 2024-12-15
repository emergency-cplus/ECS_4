class SendListsController < ApplicationController
  before_action :set_send_list, only: [:show, :edit, :update]

  def index
    @send_lists = case current_user.role
                  when 'admin'
                    SendList.viewable_for_admin
                  when 'general'
                    SendList.viewable_for_general(current_user.id)
                  when 'demo'
                    SendList.viewable_for_demo
                  end
                  .includes(:item, :user)
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
    @send_list.send_as_test = params[:send_as_test].present?

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
        is_test: @send_list.send_as_test
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
      Rails.logger.error "TwilioAPIエラー: #{e.message}"
    rescue StandardError => e
      flash[:alert] = 'エラーが発生しました'
      Rails.logger.error "予期せぬエラー: #{e.class} - #{e.message}"
      Rails.logger.error e.backtrace.join("\n")
    ensure
      redirect_to send_lists_path
    end
  end

  def update; end

  def check_limit_status
    send_list = SendList.new(user: current_user)
    render json: {
      current_count: send_list.todays_send_count,
      limit: send_list.todays_send_limit,
      remaining: [0, send_list.todays_send_limit - send_list.todays_send_count].max,
      next_reset: format_next_reset_time
    }
  end

  private

  def set_send_list
    @send_list = SendList.find(params[:id])
  end

  def send_list_params
    params.permit(:phone_number, :sender, :item_id, :send_at, :send_as_test)
  end

  def format_next_reset_time
    current = Time.current
    reset_time = current.beginning_of_day + SendList::RESET_HOUR.hours + SendList::RESET_MINUTE.minutes
    reset_time += 1.day if current >= reset_time
    reset_time.strftime('%Y-%m-%d %H:%M:%S')
  end

  # def determine_viewable_roles
  #   case current_user.role
  #   when 'admin'
  #     # 管理者は全ての履歴を閲覧可能
  #     [0, 1, 2]
  #   when 'general'
  #     # generalユーザーは自身のgeneral時代の履歴と、過去のdemo時代の履歴を閲覧可能
  #     roles = [1] # general: 1
  #     roles << 2 if current_user.was_demo? # demo: 2
  #     roles
  #   when 'demo'
  #     # demoユーザーはdemoの履歴のみ閲覧可能(現generalユーザーのdemo時代の履歴を含む)
  #     ['demo']
  #   end
  # end
end