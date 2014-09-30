require 'rest_client'
require 'json'

class Quote < ActiveRecord::Base
  include TrackingHelpers

  acts_as_paranoid
  tracked by_current_user

  belongs_to :salesperson, class_name: User
  belongs_to :store
  has_many :line_item_groups
# has_many :line_items, through: :line_item_groups

# accepts_nested_attributes_for :line_items, allow_destroy: true

  validates :email, presence: true, email: true
  validates :estimated_delivery_date, presence: true
  validates :first_name, presence: true
# validate :has_line_items?
  validates :last_name, presence: true
  validates :salesperson, presence: true
  validates :store, presence: true
  validates :valid_until_date, presence: true
  validates :shipping, price: true

  validate :prepare_nested_line_items_attributes
  after_save :save_nested_line_items_attributes

  def all_activities
    PublicActivity::Activity.where( '
      (
        activities.recipient_type = ? AND activities.recipient_id = ?
      ) OR
      (
        activities.trackable_type = ? AND activities.trackable_id = ?
      )
    ', *([self.class.name, id] * 2) ).order('created_at DESC')
  end

  def create_freshdesk_ticket(current_user)
    config = FreshdeskModule.get_freshdesk_config(current_user)
    client = FreshdeskModule.open_connection(config)
    freshdesk_info = fetch_data_to_h(config)

    client.post_tickets(
      email: email,
      requester_id: freshdesk_info[:requester_id],
      requester_name: freshdesk_info[:requester_name],
      source: 2,
      group_id: freshdesk_info[:group_id],
      ticket_type: 'Lead',
      subject: 'Created by Softwear-CRM',
      custom_field: { department_7483: freshdesk_info[:department] }
    )
  end

  def formatted_phone_number
    if phone_number
      area_code    = phone_number[0, 3]
      middle_three = phone_number[3, 3]
      last_four    = phone_number[6, 4]
      "(#{area_code}) #{middle_three}-#{last_four}"
    end
  end

  def line_items
    line_item_groups.flat_map(&:line_items).tap do |groups|
      groups.send(
        :define_singleton_method,
        :klass, -> { LineItem }
      )
    end
  end

  def line_items_attributes=(attributes)
    @line_item_attributes ||= []
    @line_item_attributes += attributes.values
  end

  def full_name
    "#{first_name} #{last_name}"
  end

  def has_line_items?
    line_items.empty?
  end

  def line_items_subtotal
    line_items.map(&:total_price).reduce(0, :+)
  end

  def line_items_total_tax
    line_items.map{ |l| l.taxable? ? l.total_price * tax : 0 }.reduce(0, :+)
  end

  def line_items_total_with_tax
    line_items.map { |l| l.taxable? ? l.total_price * (1 + tax) : l.total_price }.reduce(0, :+) + shipping
  end

  alias_method :standard_line_items, :line_items

  def tax
    0.06
  end

  def default_group
    line_item_groups.first ||
    line_item_groups.create(
      name: @default_group_name || 'Line Items',
      description: 'Initial of line items in the quote'
    )
  end

private

  def prepare_nested_line_items_attributes
    no_attributes = @line_item_attributes.nil? || @line_item_attributes.empty?
    if no_attributes && line_items.empty?
      errors.add(:must, 'have at least one line item')
      return false
    end
    return if no_attributes

    @unsaved_line_items = @line_item_attributes.map do |attrs|
        next if attrs.delete('_destroy') == 'true'
        line_item = LineItem.new(attrs)
        next line_item if line_item.valid?

        errors.add(:line_items, line_item.errors.full_messages.join(', '))
        nil
      end
        .compact

    nil
  end

  def save_nested_line_items_attributes
    return if @unsaved_line_items.nil? || @unsaved_line_items.empty?

    @unsaved_line_items.each(&default_group.line_items.method(:<<))
    @unsaved_line_items = nil
  end

  def fetch_data_to_h(config)
    freshdesk_info = {}
    freshdesk_info = fetch_group_id_and_dept(freshdesk_info)
    fetch_requester_id_and_name(freshdesk_info, config)
  end

  def fetch_group_id_and_dept(old_hash)
    new_hash = {}
    if store.name.downcase.include? 'arbor'
#     Hardcoded id's are the ones freshdesk uses for AA and Ypsi sales dept
      new_hash[:group_id]   = 86316
      new_hash[:department] = 'Sales - Ann Arbor'
    elsif store.name.downcase.include? 'ypsi'
      new_hash[:group_id]   = 86317
      new_hash[:department] = 'Sales - Ypsilanti'
    else
      new_hash[:group_id]   = nil
      new_hash[:department] = nil
    end
    old_hash.merge(new_hash)
  end

  def fetch_requester_id_and_name(old_hash, config)
    parsed_json = get_customer(config, email)

    new_hash = {}
    if parsed_json.nil?
#     no customer found, create new customer
      new_hash = create_freshdesk_customer
    else
#     customer found, create ticket with his credentials
      new_hash[:requester_name] = parsed_json['user']['name']
      new_hash[:requester_id] = parsed_json['user']['id']
    end

    old_hash.merge(new_hash)
  end

  def create_freshdesk_customer
    response = post_request_for_new_customer
    parsed_xml = Hash.from_xml(response.body)

    new_hash = {}
    new_hash[:requester_name] = parsed_xml['user']['name']
    new_hash[:requester_id] = parsed_xml['user']['id']

    new_hash
  end

  def post_request_for_new_customer
    uri = URI.parse("#{ Figaro.env['freshdesk_url'] }/contacts.xml")

    request = Net::HTTP::Post.new(uri.request_uri)
    request.basic_auth(Figaro.env['freshdesk_email'], Figaro.env['freshdesk_password'])

    request['Content-Type'] = 'application/xml'

    connection = Net::HTTP.new(uri.host, uri.port)

    post_data = {}
    post_data['user[name]']  = "#{first_name} #{last_name}"
    post_data['user[email]'] = email

    request.set_form_data(post_data)
    connection.request(request)
  end
end
