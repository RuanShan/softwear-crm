require 'rest_client'
require 'json'
require 'action_view'

class Quote < ActiveRecord::Base
  include TrackingHelpers
  include IntegratedCrms
  include ActionView::Helpers::DateHelper

  acts_as_paranoid
  tracked by_current_user
  get_insightly_api_key_from { salesperson.try(:insightly_api_key) }

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
  after_create :create_freshdesk_ticket
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

  def freshdesk_ticket_link
    return if freshdesk_ticket_id.blank?
    "http://annarbortees.freshdesk.com/helpdesk/tickets/#{freshdesk_ticket_id}"
  end

  def description
    quote_requests.map do |qr|
      qr.description
    end
      .join("\n")
  end

  def create_freshdesk_ticket
    return if freshdesk.nil? || !freshdesk_ticket_id.blank?
    return if quote_requests.empty?

    begin
      ticket = JSON.parse(freshdesk.post_tickets(
          helpdesk_ticket: {
            requester_id: quote_requests.first.try(:freshdesk_contact_id),
            requester_name: full_name,
            source: 2,
            group_id: freshdesk_group_id,
            ticket_type: 'Lead',
            subject: 'Created by Softwear-CRM',
            custom_field: {
              department_7483: freshdesk_department,
              softwearcrm_quote_id_7483: id
            },
            description_html: freshdesk_description
          }
        ))
        .try(:[], 'helpdesk_ticket')

      self.freshdesk_ticket_id = ticket.try(:[], 'id')
      ticket

    rescue Freshdesk::ConnectionError => e
      logger.error "(QUOTE - FRESHDESK) #{e.message}"
    end
  end

  # NOTE this is unused (but reserved in case it seems handy)
  def fetch_freshdesk_ticket(from_email = 'crm@softwearcrm.com')
    begin
      tickets = JSON.parse(freshdesk.get_tickets(
        email: from_email,
        filter_name: 'all_tickets'
      ))
      # We only get a hash on error... better way to check?
      return if tickets.is_a?(Hash)

      ticket = tickets.find do |ticket|
        doc = Nokogiri::XML(ticket['description_html'])
        quote_id = doc.at_css('#softwear_quote_id').text.to_i

        quote_id == id.to_i
      end

      if ticket.nil?
        logger.error 'NO SUCH TICKET FOUND'
        return
      end

      self.freshdesk_ticket_id = ticket['display_id']

    rescue Freshdesk::ConnectionError => e
      logger.error "(QUOTE - FRESHDESK) #{e.message}"
    end
  end

  # NOTE This is also unused (keeping in case it might be useful)
  def set_freshdesk_ticket_requester
    begin
      return if freshdesk_ticket_id.blank?

      if (contact_id = freshdesk_contact_id).nil?
        logger.error "(QUOTE #{id} - FRESHDESK) No quote"
        return
      end

      response = freshdesk.put_tickets(
        id: freshdesk_ticket_id,
        helpdesk_ticket: {
          requester_id: contact_id,
          source: 2,
          group_id: freshdesk_group_id,
          ticket_type: 'Lead',
          custom_field: {
            softwearcrm_quote_id_7483: id
          }
        }
      )

    rescue Freshdesk::ConnectionError => e
      logger.error "(QUOTE #{id} - FRESHDESK) #{e.message}"
    end
  end


  def create_insightly_opportunity
    return if insightly.nil?

    begin
      self.insightly_opportunity_id = insightly.create_opportunity(
        opportunity: {
          opportunity_name: name,
          opportunity_state: 'Open',
          opportunity_details: insightly_description,
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

  def insightly_description
    return description if freshdesk_ticket_id.blank?
    "#{description}\n#{freshdesk_ticket_link}"
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

  def freshdesk_group_id
    name = salesperson.store.try(:name).try(:downcase) || ''
    if name.include? 'ypsi'
      86317 # Group ID of Sales - Ypsilanti within Freshdesk
    else
      86316 # Group ID of Sales - Ann Arbor within Freshdesk
    end
  end
  def freshdesk_department
    name = salesperson.store.try(:name).try(:downcase) || ''
    if name.include? 'arbor'
      'Sales - Ann Arbor'
    elsif name.include? 'ypsi'
      'Sales - Ypsilanti'
    end
  end

  def freshdesk_contact_id
    quote_requests
      .where("freshdesk_contact_id <> ''")
      .pluck(:freshdesk_contact_id)
      .first
  end

  def freshdesk_description
    r = ApplicationController.new
    quote_requests
      .where("freshdesk_contact_id <> ''")
      .reduce('') do |description, quote_request|
        r.render_string(
          template: nil,
          partial: 'quote_requests/basic_table',
          locals: { quote_request: quote_request }
        )
      end
      .html_safe
  end


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

  def subtract_dates(time_one, time_two)
    return 'An email hasn\'t been sent yet!' unless time_two
    distance_of_time_in_words(time_one, time_two)
  end
end
