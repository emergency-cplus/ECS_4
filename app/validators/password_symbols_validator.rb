class PasswordSymbolsValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    unless value =~ /\A(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[!@#$%^&*()_+\-]).{8,}\z/
      record.errors.add(attribute, (options[:message] || "は半角の英数字および記号 !@#$%^&*()_+- をそれぞれ1つ以上含む必要があります(大文字と小文字は区別されます)"))
    end
  end
end
