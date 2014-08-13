require 'rest_client'
require 'json'

class Quote < ActiveRecord::Base
  include TrackingHelpers

  acts_as_paranoid
  tracked by_current_user

  belongs_to :salesperson, class_name: User
  belongs_to :store
  has_many :line_items, as: :line_itemable

  accepts_nested_attributes_for :line_items, allow_destroy: true

  validates :email, presence: true, email: true
  validates :estimated_delivery_date, presence: true
  validates :first_name, presence: true
  validate :has_line_items?
  validates :last_name, presence: true
  validates :salesperson, presence: true
  validates :store, presence: true
  validates :valid_until_date, presence: true

  def all_activities
    # TODO: use string literal? also general style
    PublicActivity::Activity.where( '
      (
        activities.recipient_type = ? AND activities.recipient_id = ?
      ) OR
      (
        activities.trackable_type = ? AND activities.trackable_id = ?
      )
    ', *([self.class.name, id] * 2) ).order('created_at DESC')
  end

  def create_freshdesk_customer
    response = post_request_for_new_customer
    parsed_xml = Hash.from_xml(response.body)

    new_hash = {}
    new_hash[:requester_name] = parsed_xml['user']['name']
    new_hash[:requester_id] = parsed_xml['user']['id']

    new_hash
  end

  def create_freshdesk_ticket(current_user)
    freshdesk_info = fetch_data_to_h(current_user)

    client = Freshdesk.new(Figaro.env['freshdesk_url'],
                           Figaro.env['freshdesk_email'],
                           Figaro.env['freshdesk_password'])

    client.post_tickets(
      email: email,
      requester_id: freshdesk_info[:requester_id],
      requester_name: freshdesk_info[:requester_name],
      source: 2,
      group_id: freshdesk_info[:group_id],
      ticket_type: 'Lead',
      subject: 'Ignore this ticket',
      custom_field: { department_7483: freshdesk_info[:department] }
    )
  end

  def fetch_data_to_h(_current_user)
    freshdesk_info = {}
    freshdesk_info = fetch_group_id_and_dept(freshdesk_info)
    fetch_requester_id_and_name(freshdesk_info)
  end

  def fetch_group_id_and_dept(old_hash)
    new_hash = {}
    if store.name.downcase.include? 'arbor'
      # HACK: pretty sure this is the id freshdesk uses for Sales - Ann Arbor
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

  def fetch_requester_id_and_name(old_hash)
    params = URI.escape("query=email is #{email}")
    site = RestClient::Resource.new("#{ Figaro.env['freshdesk_url'] }/contacts.json?state=all&#{params}", Figaro.env['freshdesk_email'], Figaro.env['freshdesk_password'])

    response = site.get(accept: 'application/json')

    new_hash = {}
    if response.body == '[]'
      # no customer found, create new customer
      new_hash = create_freshdesk_customer
    else
      # customer found, create ticket with his credentials
      parsed_json = JSON.parse(response.body)[0]
      new_hash[:requester_name] = parsed_json['user']['name']
      new_hash[:requester_id] = parsed_json['user']['id']
    end

    old_hash.merge(new_hash)
  end

  def formatted_phone_number
    if phone_number
      area_code    = phone_number[0, 3]
      middle_three = phone_number[3, 3]
      last_four    = phone_number[6, 4]
      "(#{area_code}) #{middle_three}-#{last_four}"
    end
  end

  def full_name
    "#{first_name} #{last_name}"
  end

  def has_line_items?
    errors.add(:base, 'Quote must have at least one line item') if self.line_items.blank?
  end

  def line_items_subtotal
    line_items.map(&:total_price).reduce(0, :+)
  end

  def line_items_total_tax
    line_items.map{ |l| l.taxable? ? l.total_price * tax : 0 }.reduce(0, :+)
  end

  def line_items_total_with_tax
    line_items.map { |l| l.taxable? ? l.total_price * (1 + tax) : l.total_price }.reduce(0, :+)
  end

  def post_request_for_new_customer
    uri = URI.parse("#{ Figaro.env['freshdesk_url'] }/contacts.xml")

    request = Net::HTTP::Post.new(uri.request_uri)
    request.basic_auth(Figaro.env['freshdesk_email'], Figaro.env['freshdesk_password'])

    request['Content-Type'] = 'application/xml'

    connection = Net::HTTP.new(uri.host, uri.port)
    post_data = Hash.new

    post_data['user[name]']  = "#{first_name} #{last_name}"
    post_data['user[email]'] = email

    request.set_form_data(post_data)
    connection.request(request)
  end

  def standard_line_items
    LineItem.non_imprintable.where(line_itemable_id: id, line_itemable_type: 'Quote')
  end

  def tax
    0.06
  end
end
