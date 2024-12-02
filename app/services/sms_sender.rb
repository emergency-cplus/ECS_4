class SmsSender
  def initialize
    @client = Twilio::REST::Client.new(
      ENV['TWILIO_ACCOUNT_SID'],
      ENV['TWILIO_AUTH_TOKEN']
    )
  end

  def send_sms(to:, body:, item:, is_test: false)
    formatted_phone_number = format_phone_number(to)
    return unless formatted_phone_number

    begin
      Rails.logger.info "Twilioクレデンシャル確認: SID=#{ENV['TWILIO_ACCOUNT_SID']&.first(6)}..."
      Rails.logger.info "送信元番号: #{ENV['TWILIO_PHONE_NUMBER']}"
      
      # メッセージ本文を構築
      message_body = build_message(item, is_test)
      
      response = @client.messages.create(
        from: ENV['TWILIO_PHONE_NUMBER'],
        to: formatted_phone_number,
        body: message_body
      )
      
      Rails.logger.info "Twilioレスポンス: #{response.status}"
      response
      
    rescue => e
      Rails.logger.error "Twilioエラー詳細: #{e.class}: #{e.message}"
      Rails.logger.error e.backtrace.join("\n")
      raise
    end
  end

  private

  def format_phone_number(number)
    return unless number.present?
    number = number.gsub(/[-\s]/, '')
    number = "+81#{number[1..-1]}" if number.start_with?('0')
    number
  end

  def build_message(item, is_test)
    # テストメッセージの場合は先頭に[テスト]を付ける
    prefix = is_test ? "[テスト] " : ""
    
    # メッセージ本文を構築
    message = "#{prefix}#{item.user.name}から送信されました。\n"
    message += "#{item.item_url}"

    message
  end
end