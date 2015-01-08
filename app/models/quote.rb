require 'rest_client'
require 'json'
require 'action_view'

class Quote < ActiveRecord::Base
  include TrackingHelpers

  acts_as_paranoid
  default_scope { order('created_at DESC') }
  paginates_per 50
  tracked by_current_user

  searchable do
    text :email, :first_name, :last_name, :name, :company, :twitter, :phone_number,
         :quote_source, :freshdesk_ticket_id
  end

  QUOTE_SOURCES = [
    'Phone Call',
    'E-mail',
    'Walk In',
    'Online Form',
    'Other'
  ]

  belongs_to :salesperson, class_name: User
  belongs_to :store
  has_many :email_templates
  has_many :emails, as: :emailable, class_name: Email, dependent: :destroy
  has_many :line_item_groups
# has_many :line_items, through: :line_item_groups
  has_many :quote_request_quotes
  has_many :quote_requests, through: :quote_request_quotes
  has_many :order_quotes
  has_many :orders, through: :order_quotes

# accepts_nested_attributes_for :line_items, allow_destroy: true

  validates :email, presence: true, email: true
  validates :estimated_delivery_date, presence: true
  validates :first_name, presence: true
# validate :has_line_items?
  validates :last_name, presence: true
  validates :quote_source, presence: true
  validates :salesperson, presence: true
  validates :store, presence: true
  validates :valid_until_date, presence: true
  validates :shipping, price: true

  validate :prepare_nested_line_items_attributes

  after_save :save_nested_line_items_attributes
  after_save :set_quote_request_statuses_to_quoted
  after_initialize  :initialize_time

  def all_activities
    PublicActivity::Activity.where( '
      (
        activities.recipient_type = ? AND activities.recipient_id = ?
      ) OR
      (
        activities.trackable_type = ? AND activities.trackable_id = ?
      )
    ', *([self.class.name, id] * 2) ).order('activities.created_at DESC')
  end

# TODO: this is broken so don't use it yet lulz
  def create_freshdesk_ticket(current_user)
    config = FreshdeskModule.get_freshdesk_config(current_user)
    client = FreshdeskModule.open_connection(config)
    FreshdeskModule.send_ticket(client, config, self)
  end

  def no_ticket_id_entered?
    freshdesk_ticket_id.blank?
  end

  def no_fd_login?(current_user)
    config = FreshdeskModule.get_freshdesk_config(current_user)
    if config.has_key?(:freshdesk_email) && config.has_key?(:freshdesk_password)
      false
    else
      true
    end
  end

  def has_freshdesk_ticket?(current_user)
    response = get_freshdesk_ticket current_user
    response.quote_fd_id_configured ? false : true
  end

  # this function assumes that the following functions are called beforehand
  # with the same user (and therefore doesn't bother checking if they're true or false):
  #   no_ticket_id_entered
  #   no_fd_login
  def get_freshdesk_ticket(current_user)
    # logic for getting freshdesk ticket
    # Once it grabs ticket, if CRM Quote ID not set, set it
    # https://github.com/AnnArborTees/softwear-mockbot/blob/release-2014-10-17/app/models/spree/store.rb
    Rails.cache.fetch(:quote_fd_ticket, :expires => 30.minutes) do
      config = FreshdeskModule.get_freshdesk_config(current_user)
      client = Freshdesk.new(config[:freshdesk_url], config[:freshdesk_email], config[:freshdesk_password])
      client.response_format = 'json'

      ticket = client.get_tickets(freshdesk_ticket_id)
      ticket = '{ "quote_fd_id_configured": "false" }' if ticket.nil?
      return OpenStruct.new JSON.parse(ticket)
    end
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

  def response_time
    subtract_dates(initialized_at, time_to_first_email)
  end

  def quote_request_ids=(ids)
    super
    @quote_request_ids_assigned = true
  end

private

  def set_quote_request_statuses_to_quoted
    return unless @quote_request_ids_assigned

    quote_requests.find_each { |q| q.update_attributes(status: 'quoted') }

    @quote_request_ids_assigned = nil
  end

  def initialize_time
    self.initialized_at = Time.now if self.initialized_at.blank?
  end

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

  def time_to_first_email
    activity = PublicActivity::Activity.where(trackable_id: id,
                                              trackable_type: Quote,
                                              key: 'quote.emailed_customer').order('activities.created_at ASC').first
    activity.nil? ? nil : activity.created_at
  end

  include ActionView::Helpers::DateHelper
  def subtract_dates(time_one, time_two)
    return 'An email hasn\'t been sent yet!' unless time_two
    distance_of_time_in_words(time_one, time_two)
  end
end
