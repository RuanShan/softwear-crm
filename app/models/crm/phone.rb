class Crm::Phone < ActiveRecord::Base
  belongs_to :contact, class_name: 'Crm::Contact'

  validates :number, presence: true
  validates :number,
            format: {
              with: /\d{3}-\d{3}-\d{4}/,
              message: 'is incorrectly formatted, use 000-000-0000'
            }

  def full_number
    if extension.blank?
      number
    else
      "#{number}x#{extension}"
    end
  end
end
