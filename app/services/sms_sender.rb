class SmsSender
  def initialize
    @client = Twilio::REST::Client.new(ENV['TWILIO_ACCOUNT_SID'], ENV['TWILIO_AUTH_TOKEN'])
  end

  # SMSを送信するメソッド
  def send_sms(to:, body:)
    @client.messages.create(
      from: ENV['TWILIO_PHONE_NUMBER'], # 送信元の電話番号
      to: to,                           # 送信先の電話番号
      body: body                        # 送信するメッセージ本文
    )
  end
end
