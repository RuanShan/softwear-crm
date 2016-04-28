class Crm::Phone < ActiveRecord::Base
  belongs_to :contact, class_name: 'Crm::Contact'

  validates :number, presence: true
  validates :number,
            format: {
              with: /\d{3}-\d{3}-\d{4}/,
              message: 'is incorrectly formatted, use 000-000-0000'
            }

  before_validation :reformat_number

  def full_number
    if extension.blank?
      number
    else
      "#{number}x#{extension}"
    end
  end

  private

  def reformat_number
    unless /\d{3}-\d{3}-\d{4}/.match(number)
      number.insert(6, '-').insert(3, '-')
    end
  end

end
