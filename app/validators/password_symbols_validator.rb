class PasswordSymbolsValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    unless /\A(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[!@#$%^&*()_+\-]).{8,}\z/.match?(value)
      record.errors.add(attribute, (options[:message] || "は半角の英字、数字、記号で、それぞれ1つ以上含む必要があります(大文字、小文字は区別されます)。"))
    end
  end
end
