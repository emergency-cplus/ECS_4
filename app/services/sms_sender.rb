class SmsSender
  def initialize
    @client = Twilio::REST::Client.new(ENV['TWILIO_ACCOUNT_SID'], ENV['TWILIO_AUTH_TOKEN'])
  end

  def send_sms(to:, body:, item:)
    formatted_phone_number = format_phone_number(to)
    return unless formatted_phone_number

    user_message = User.find(item.user_id).message_template
    full_body = "#{user_message} #{item.item_url} 身に覚えのない場合は無視してください。"

    @client.messages.create(
      from: ENV['TWILIO_PHONE_NUMBER'],
      to: formatted_phone_number,
      body: full_body
    )
  end

  private

  # 電話番号を国際形式にフォーマット
  def format_phone_number(phone_number)
    phone_number = phone_number.gsub(/\D/, '') # 数字のみ取り出す
    return nil unless phone_number.length == 10 || phone_number.length == 11
    "+81#{phone_number[1..]}"
  end
end
