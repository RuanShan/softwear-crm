require 'rest_client'
require 'json'
require 'action_view'

class Quote < ActiveRecord::Base
  include TrackingHelpers
  include IntegratedCrms
  include ActionView::Helpers::DateHelper

  acts_as_paranoid
  acts_as_commentable :public, :private
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
  STEP_5_FIELD = [
    :all_comments
  ]
  INSIGHTLY_FIELDS = [
    :insightly_category_id,
    :insightly_probability,
    :insightly_value,
    :insightly_pipeline_id,
    :insightly_opportunity_profile_id,
    :insightly_bid_amount,
    :insightly_bid_tier_id,
    :insightly_opportunity_id
  ]

  MARKUPS_AND_OPTIONS_JOB_NAME = '_markupsandoptions_'

  default_scope -> { order('quotes.created_at DESC') }

  belongs_to :salesperson, class_name: User
  belongs_to :store
  has_many :email_templates
  has_many :emails, as: :emailable, class_name: Email, dependent: :destroy
  has_many :quote_request_quotes
  has_many :quote_requests, through: :quote_request_quotes
  has_many :order_quotes
  has_many :orders, through: :order_quotes
  has_many :jobs, as: :jobbable
  has_many :line_items, through: :jobs

  validates :email, presence: true, email: true
  validates :estimated_delivery_date, presence: true
  validates :first_name, presence: true
  validates :quote_source, presence: true
  validates :salesperson, presence: true
  validates :store, presence: true
  validates :valid_until_date, presence: true
  validates :shipping, price: true
  validates *(INSIGHTLY_FIELDS - [:insightly_opportunity_id]), presence: true, if: :salesperson_has_insightly?

  after_save :set_quote_request_statuses_to_quoted
  after_create :enqueue_create_freshdesk_ticket
  after_create :enqueue_create_insightly_opportunity
  before_create :set_default_valid_until_date
  after_initialize  :initialize_time

  alias_method :comments, :all_comments
  alias_method :comments=, :all_comments=
  alias_method :notes, :all_comments
  alias_method :notes=, :all_comments=
  alias_method :public_notes, :public_comments
  alias_method :public_notes=, :public_comments=
  alias_method :private_notes, :private_comments
  alias_method :private_notes=, :private_comments=

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

  def show_quoted_email_text
    html_doc = Nokogiri::HTML()
  end

  def markups_and_options_job
    attrs = {
      name: MARKUPS_AND_OPTIONS_JOB_NAME,
      description: 'hidden'
    }
    jobs.where(attrs).first or jobs.create(attrs)
  end

  def standard_line_items
    markups_and_options_job.line_items
  end

  def imprintable_jobs
    jobs.where.not(name: MARKUPS_AND_OPTIONS_JOB_NAME)
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

  def tax
    0.06
  end

  def response_time
    subtract_dates(initialized_at, time_to_first_email)
  end

  def quote_request_ids=(ids)
    super
    @quote_request_ids_assigned = true
  end

  # This is accessed by the 'fields_for' view helper
  def line_items_from_group
    OpenStruct.new(
      imprintable_group_id: nil,
      quantity: nil,
      decoration_price: nil,
      persisted: false
    )
  end
  def line_items_from_group_attributes=(attrs)
    imprintable_group = ImprintableGroup.find attrs[:imprintable_group_id]
    quantity          = attrs[:quantity]
    decoration_price  = attrs[:decoration_price]

    new_line_items = Imprintable::TIERS.keys.map do |tier|
      imprintable = imprintable_group.default_imprintable_for_tier(tier)

      next if imprintable.nil?

      line_item = LineItem.new
      line_item.quantity          = quantity
      line_item.decoration_price  = decoration_price
      line_item.imprintable_price = imprintable.base_price
      line_item.imprintable_variant_id =
        imprintable.imprintable_variants.first.try(:id)

      next if line_item.imprintable_variant_id.nil?

      line_item.tier = tier

      line_item
    end
      .compact

    new_job = Job.new
    new_job.name        = imprintable_group.name
    new_job.description = imprintable_group.description
    new_job.line_items  = new_line_items
    new_job.save!

    attrs[:print_locations].try(:each_with_index) do |print_location_id, index|
      imprint = Imprint.new
      imprint.print_location_id = print_location_id
      imprint.description = attrs[:imprint_descriptions][index]
      imprint.job_id = new_job.id
      imprint.save!
    end

    self.jobs << new_job
    self.save!
  end

  def line_item_to_group
    OpenStruct.new(
      imprintables: nil,
      job_id: nil,
      tier: nil,
      quantity: nil,
      decoration_price: nil,
      persisted: false
    )
  end
  def line_item_to_group_attributes=(attrs)
    job = jobs.find_by id: attrs[:job_id]
    # NOTE I don't think this actually happens in the field, but in tests
    # I can't query off of `jobs` at all... And this happens to do it.
    if job.nil?
      job = jobs.find { |j| j.id == attrs[:job_id].to_i }
    end

    # NOTE it is assumed that the job passed is valid. (The interface shouldn't
    # allow an invaild one.)
    return if job.nil?

    attrs[:imprintables].map do |imprintable_id|
      imprintable = Imprintable.find imprintable_id

      line_item = LineItem.new
      line_item.line_itemable     = job
      line_item.tier              = attrs[:tier] || Imprintable::TIER.good
      line_item.quantity          = attrs[:quantity] || 1
      line_item.decoration_price  = attrs[:decoration_price] || 0
      line_item.imprintable_price = imprintable.base_price
      line_item.imprintable_variant_id =
        imprintable.imprintable_variants.pluck(:id).first
      # TODO error out if that imprintable variant id is nil

      line_item.save!
    end
  end

  def salesperson_has_insightly?
    !salesperson.try(:insightly_api_key).blank?
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

  def assign_from_quote_request(quote_request)
    if /(?<qr_first>\w+)\s+(?<qr_last>\w+)/ =~ quote_request.name
      self.first_name = qr_first
      self.last_name  = qr_last
    else
      self.first_name = quote_request.name
    end

    self.email            ||= quote_request.email
    self.qty              ||= quote_request.approx_quantity
    self.phone_number     ||= quote_request.phone_number if quote_request.phone_number
    self.company          ||= quote_request.organization if quote_request.organization
    self.quote_source     ||= 'Online Form'
    if quote_request.date_needed
      self.deadline_is_specified = true
      self.valid_until_date = quote_request.date_needed
    end
  end

  def enqueue_create_freshdesk_ticket
    self.delay(queue: 'api').create_freshdesk_ticket
  end

  def create_freshdesk_ticket
    return if freshdesk.nil? || !freshdesk_ticket_id.blank?

    begin
      if quote_requests.empty?
        requester_info = {
          email: email,
          phone: phone_number,
          name: full_name
        }
      else
        requester_info = {
          requester_id: quote_requests.first.try(:freshdesk_contact_id),
        }
      end

      ticket = JSON.parse(freshdesk.post_tickets(
          helpdesk_ticket: {
            source: 2,
            group_id: freshdesk_group_id,
            ticket_type: 'Lead',
            subject: "Your Quote (##{name}) from the Ann Arbor T-shirt Company",
            custom_field: {
              department_7483: freshdesk_department,
              softwearcrm_quote_id_7483: id
            },
            description_html: freshdesk_description
          }
           .merge(requester_info)
        ))
        .try(:[], 'helpdesk_ticket')

      self.freshdesk_ticket_id = ticket.try(:[], 'display_id')
      ticket

    rescue StandardError => e
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


  def enqueue_create_insightly_opportunity
    self.delay(queue: 'api').create_insightly_opportunity
  end

  def create_insightly_opportunity
    return if insightly.nil?

    begin
      op = insightly.create_opportunity(
        opportunity: {
          opportunity_name:    name,
          opportunity_state:   'Open',
          opportunity_details: insightly_description,
          probability:         insightly_probability.to_i,
          bid_currency:        'USD',
          bid_amount:          insightly_bid_amount.to_i,
          forecast_close_date: (created_at + 3.days).strftime('%F %T'),
          pipeline_id:         insightly_pipeline_id,
          stage_id:            insightly_stage_id,
          category_id:         insightly_category_id,
          customfields:        insightly_customfields,
          links:               insightly_contact_links,
        }
      )
      self.insightly_opportunity_id = op.opportunity_id
      self.save(validate: false)
      op
    # rescue Insightly2::Errors::ClientError => e
      # logger.error "(QUOTE - INSIGHTLY) #{e.class}: #{e.message}"
      # e
    rescue StandardError => e
      logger.error "(QUOTE - INSIGHTLY) #{e.class}: #{e.message}"
      e
    end
  end

  def insightly_stage_id
    insightly
      .get_pipeline_stages
      .find { |s| s.pipeline_id == insightly_pipeline_id && s.stage_order == 1 }
      .stage_id
  end

  def insightly_description
    return description if freshdesk_ticket_id.blank?
    "#{description}\n#{freshdesk_ticket_link}"
  end

  def insightly_contact_links
    if quote_requests.empty?
      contact = create_insightly_contact(
        first_name:   first_name,
        last_name:    last_name,
        email:        email,
        phone_number: phone_number,
        organization: company
      )

      if contact
        c = []
        c << { contact_id: contact.contact_id }
        contact.links.select{ |l| l.key?('organisation_id') }.each do |l|
          c << { organisation_id: l['organisation_id'] }
        end
        c
      else
        []
      end
    else
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

  def additional_options_and_markups
    line_items.where(imprintable_variant_id: nil)
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
