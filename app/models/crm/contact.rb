class Crm::Contact < ActiveRecord::Base
  has_many :emails, ->{order(primary: :desc)}, class_name: 'Crm::Email'
  has_many :phones, ->{order(primary: :desc)}, class_name: 'Crm::Phone'
  has_many :orders
  has_many :quotes

  has_one :primary_email, ->{ where(primary: true) }, class_name: 'Crm::Email'
  has_one :primary_phone, ->{ where(primary: true) }, class_name: 'Crm::Phone'

  validates :first_name, :last_name, presence: true
  validates :primary_email, :primary_phone, presence: true

  accepts_nested_attributes_for :emails, allow_destroy: true
  accepts_nested_attributes_for :phones, allow_destroy: true
  accepts_nested_attributes_for :primary_email
  accepts_nested_attributes_for :primary_phone

  after_initialize :initialize_phone_and_email
  before_save :there_can_only_be_one_primary

  state_machine :state, initial: :contact do
    event :submitted_quote_request do
      transition :contact => :prospect
    end

    event :placed_order do
      transition :prospect => :customer
    end

    event :placed_order do
      transition any => :client
    end

    event :demoted_to_customer do
      transition any => :customer
    end
  end

  def full_name
    "#{first_name} #{last_name}"
  end

  def phone_number
    if primary_phone.extension.blank?
      primary_phone.number
    else
      "#{primary_phone.number}x#{primary_phone.extension}"
    end
  end

  def email
    primary_email.address
  end

  private

  def initialize_phone_and_email
    self.build_primary_phone if self.primary_phone.blank?
    self.build_primary_email if self.primary_email.blank?
  end

  def there_can_only_be_one_primary
    if phones.where(primary: true).count > 1
      phones.where(primary: true).each_with_index do |x, i|
        next if i == 0
        x.update_attribute(:primary, false)
      end
    end
    if emails.where(primary: true).count > 1
      emails.where(primary: true).each_with_index do |x, i|
        next if i == 0
        x.update_attribute(:primary, false)
      end
    end
  end

end
