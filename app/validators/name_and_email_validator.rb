class NameAndEmailValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    unless value =~ /\A(.+)?\s<([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})?>\Z/i
      record.errors[attribute] << (options[:message] || "is not a valid email address. Proper format is 'Name First <email@second.com>' separated by commas ")
    end
  end
end
