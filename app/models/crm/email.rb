class Crm::Email < ActiveRecord::Base
  belongs_to :contact, class_name: 'Crm::Contact'

  validates :address, presence: true, email: true
end
