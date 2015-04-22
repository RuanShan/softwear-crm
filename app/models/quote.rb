require 'rest_client'
require 'json'
require 'action_view'

class Quote < ActiveRecord::Base
  include TrackingHelpers

  acts_as_paranoid
  tracked by_current_user

  searchable do
    text :name, :email, :first_name, :last_name,
         :company, :twitter
  end

  QUOTE_SOURCES = [
    'Phone Call',
    'E-mail',
    'Walk In',
    'Online Form',
    'Other'
  ]

  STEP_1_FIELDS = [
    :email,
    :phone_number,
    :first_name,
    :last_name,
    :company,
    :twitter
  ]
  STEP_2_FIELDS = [
    :name,
    :informal,
    :quote_source,
    :shipping,
    :valid_until_date,
    :estimated_delivery_date,
    :salesperson, :salesperson_id,
    :store,
    :freshdesk_ticket_id,
    :is_rushed,
    :qty,
    :deadline_is_specified
  ]
  STEP_4_FIELDS = [
    :line_items
  ]
  INSIGHTLY_FIELDS = [
    :insightly_category_id,
    :insightly_probability,
    :insightly_value,
    :insightly_pipeline_id,
    :insightly_opportunity_profile_id,
    :insightly_bid_amount,
    :insightly_bid_tier_id,
  ]

  default_scope -> { order('quotes.created_at DESC') }

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
  validates :quote_source, presence: true
  validates :salesperson, presence: true
  validates :store, presence: true
  validates :valid_until_date, presence: true
  validates :shipping, price: true
  validates *INSIGHTLY_FIELDS, presence: true, if: :salesperson_has_insightly?

  validate :prepare_nested_line_items_attributes

  after_save :save_nested_line_items_attributes
  after_save :set_quote_request_statuses_to_quoted
  after_create :create_insightly_opportunity
  before_create :set_default_valid_until_date
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

  def formal?
    !informal?
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

  def salesperson_has_insightly?
    !salesperson.insightly_api_key.nil?
  end

  def insightly_opportunity_profile
    @i_opportunity_profile ||= find_custom_field('OPPORTUNITY_FIELD_12', insightly_opportunity_profile_id)
  end
  def insightly_bid_tier
    @i_bid_tier ||= find_custom_field('OPPORTUNITY_FIELD_11', insightly_bid_tier_id)
  end

  def insightly_task_category
    @i_task_category ||= insightly.get_task_category(id: insightly_category_id)
  end

  def insightly_pipeline
    @i_pipeline ||= insightly.get_pipeline(id: insightly_pipeline_id)
  end

  def reload
    @insightly = nil
    @i_bid_tier = nil
    @i_task_category = nil
    @i_pipeline = nil
    @i_opportunity_profile = nil
    super
  end

  def insightly_opportunity_link
    return if insightly_opportunity_id.nil?
    "https://googleapps.insight.ly/Opportunities/details/#{insightly_opportunity_id}"
  end

  def description
    quote_requests.map do |qr|
      qr.description
    end
      .join("\n")
  end

  def create_insightly_opportunity
    return if insightly.nil?

    begin
      # TODO resolve unsure fields
      self.insightly_opportunity_id = insightly.create_opportunity(
        opportunity: {
          opportunity_name: name,
          opportunity_state: 'Open',
          opportunity_details: description,
          probability: insightly_probability.to_i,
          bid_currency: 'USD',
          bid_amount: insightly_bid_amount,
          forecast_close_date: (created_at + 3.days).strftime('%F %T'),
          pipeline_id: insightly_pipeline_id,
          customfields: insightly_customfields,
          links: insightly_contact_links,
        }
      )
        .opportunity_id
      self.save(validate: false)
    rescue Insightly2::Errors::ClientError => _e
      nil
    end
  end

  def insightly_contact_links
    quote_requests.flat_map do |qr|
      c = []
      c << { contact_id: qr.insightly_contact_id }
      if qr.insightly_organisation_id
        c << { organisation_id: qr.insightly_organisation_id }
      end
      c
    end
      .uniq
  end

  def insightly_customfields
    fields = []
    if insightly_opportunity_profile_id
      fields << {
        custom_field_id: 'OPPORTUNITY_FIELD_12',
        field_value: insightly_opportunity_profile.option_value
      }
    end
    if insightly_bid_tier_id
      fields << {
        custom_field_id: 'OPPORTUNITY_FIELD_11',
        field_value: insightly_bid_tier.option_value
      }
    end
    fields << {
      custom_field_id: 'OPPORTUNITY_FIELD_3',
      field_value: yes_or_no(deadline_is_specified?)
    }
    fields << {
      custom_field_id: 'OPPORTUNITY_FIELD_5',
      field_value: yes_or_no(is_rushed?)
    }
    if is_rushed?
      fields << {
        custom_field_id: 'OPPORTUNITY_FIELD_1',
        field_value: estimated_delivery_date.strftime('%F %T')
      }
    end
    fields << {
      custom_field_id: 'OPPORTUNITY_FIELD_2',
      field_value: qty
    }
    fields << {
      custom_field_id: 'OPPORTUNITY_FIELD_10',
      field_value: 'Online - WordPress Quote Request'
    }
    fields
  end

  private

  def set_default_valid_until_date
    return unless valid_until_date.nil?
    self.valid_until_date = 30.days.from_now
  end

  def yes_or_no(bool)
    bool ? 'Yes' : 'No'
  end

  def find_custom_field(field_id, option_id)
    return if insightly.nil? || option_id.nil?

    insightly.get_custom_field(id: field_id)
      .custom_field_options
      .find { |f| f['option_id'].to_i == option_id }
      .tap { |f| return OpenStruct.new(f) if f }
  end

  def insightly
    if salesperson && salesperson.insightly_api_key
      @insightly ||= Insightly2::Client.new(salesperson.insightly_api_key)
    end
  end

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
