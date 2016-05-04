class Crm::Phone < ActiveRecord::Base
  belongs_to :contact, class_name: 'Crm::Contact'

  validates :number, presence: true
  validate :phone_number_formatted_correctly

  before_validation :reformat_number

  def full_number
    if extension.blank?
      number
    else
      "#{number}x#{extension}"
    end
  end

  private

  # message: 'is incorrectly formatted, use 000-000-0000'
  def phone_number_formatted_correctly
    return if number.blank? || number =~ /\d{3}-\d{3}-\d{4}/

    d = number.each_char.select { |c| c =~ /\d/ }
    if d.size < 10
      errors.add(:number, "is incorrectly formatted, use 000-000-0000")
      return
    end

    self.number = "#{d[0..2].join}-#{d[3..5].join}-#{d[6..9].join}"
  end

  def reformat_number
    if number && /\d{3}\d{3}\d{4}/.match(number)
      number.insert(6, '-').insert(3, '-')
    end
  end

end
