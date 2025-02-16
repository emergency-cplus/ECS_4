class TwilioClient
  def initialize
    @client = Twilio::REST::Client.new(
      ENV['TWILIO_ACCOUNT_SID'],
      ENV['TWILIO_AUTH_TOKEN']
    )
  end

  # bodyパラメータは不要なので削除
  def send_sms(to:, item:, sender_user:, is_test: false)
    formatted_phone_number = format_phone_number(to)
    return unless formatted_phone_number

    begin
      Rails.logger.info "Twilioクレデンシャル確認: SID=#{ENV['TWILIO_ACCOUNT_SID']&.first(6)}..."
      Rails.logger.info "送信元番号: #{ENV['TWILIO_PHONE_NUMBER']}"
      
      message_body = build_message(item, sender_user, is_test)
      
      response = @client.messages.create(
        from: ENV['TWILIO_PHONE_NUMBER'],
        to: formatted_phone_number,
        body: message_body
      )
      
      Rails.logger.info "Twilioレスポンス: #{response.status}"
      response
      
    rescue StandardError => e
      Rails.logger.error "Twilioエラー詳細: #{e.class}: #{e.message}"
      Rails.logger.error e.backtrace.join("\n")
      raise
    end
  end

  private

  def format_phone_number(number)
    return if number.blank?

    number = number.gsub(/[-\s]/, '')
    number = "+81#{number[1..]}" if number.start_with?('0')
    number
  end

  def build_message(item, sender_user, is_test)
    prefix = is_test ? "[テスト] " : ""
    
    message = "#{prefix}#{sender_user.name}から送信されました。\n"
    message += item.item_url.to_s

    message
  end
end
