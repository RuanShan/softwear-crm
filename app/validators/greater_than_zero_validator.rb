class GreaterThanZeroValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    unless value && value > 0
      record.errors[attribute] << (options[:message] || 'must be greater than zero')
    end
  end
end
