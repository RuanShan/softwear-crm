class PriceValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    unless value.to_s =~ /^\d+(\.\d{0,2})?$/
      record.errors[attribute] << (options[:message] || 'is not a valid price')
    end
  end
end
