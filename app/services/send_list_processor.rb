class SendListProcessor
  def initialize(send_list, current_user)
    @send_list = send_list
    @current_user = current_user
  end

  def execute
    return false unless @send_list.valid?

    item = find_item
    return false unless item

    response = send_sms_with_error_handling(item)
    handle_sms_response(response)
  end

  private

  def find_item
    Item.find(@send_list.item_id)
  rescue ActiveRecord::RecordNotFound
    @send_list.errors.add(:base, 'アイテムが見つかりませんでした')
    nil
  end

  def send_sms_with_error_handling(item)
    sms_sender = TwilioClient.new
    sms_sender.send_sms(
      to: @send_list.phone_number,
      item:,
      sender_user: @current_user,
      is_test: @send_list.send_as_test
    )
  rescue Twilio::REST::TwilioError => e
    handle_twilio_error(e)
    nil
  end

  def handle_sms_response(response)
    if response&.status == 'queued'
      @send_list.save!
      true
    else
      @send_list.errors.add(:base, 'SMSの送信に失敗しました')
      false
    end
  end

  def handle_twilio_error(error)
    Rails.logger.error "TwilioAPIエラー: #{error.message}"
    @send_list.errors.add(:base, "SMS送信エラー: #{error.message}")
  end
end
