class SendListsController < ApplicationController
  before_action :set_send_list, only: [:show, :edit, :update]

  def index
    @send_lists = fetch_send_lists
  end

  def show; end
  def new
    @send_list = SendList.new
  end
  def edit; end

  def create
    @send_list = build_send_list
    service = SendListProcessor.new(@send_list, current_user)
    
    if service.execute
      flash[:notice] = success_message
    else
      flash[:alert] = @send_list.errors.full_messages.join(', ')
    end

    redirect_to send_lists_path
  end

  def update; end

  def check_limit_status
    send_list = SendList.new(user: current_user)
    render json: build_limit_status(send_list)
  end

  private

  def fetch_send_lists
    base_query = case current_user.role
                 when 'admin' then SendList.viewable_for_admin
                 when 'general' then SendList.viewable_for_general(current_user.id)
                 when 'demo' then SendList.viewable_for_demo
                 end

    base_query.includes(:item, :user)
              .order(created_at: :desc)
              .page(params[:page])
              .per(20)
  end

  def build_send_list
    SendList.new(send_list_params).tap do |list|
      list.user = current_user
      list.send_at = Time.current
      list.send_as_test = params[:send_as_test].present?
    end
  end

  def success_message
    @send_list.send_as_test ? 'テストSMSを送信しました' : 'SMSを送信しました'
  end

  def build_limit_status(send_list)
    {
      current_count: send_list.todays_send_count,
      limit: send_list.todays_send_limit,
      remaining: [0, send_list.todays_send_limit - send_list.todays_send_count].max,
      next_reset: format_next_reset_time
    }
  end

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
end
