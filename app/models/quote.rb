require 'rest_client'
require 'json'
require 'action_view'

class Quote < ActiveRecord::Base
  include TrackingHelpers
  include IntegratedCrms
  include ActionView::Helpers::DateHelper
  include Softwear::Auth::BelongsToUser

  acts_as_paranoid
  acts_as_commentable :public, :private
  acts_as_warnable
  tracked by_current_user
  get_insightly_api_key_from { salesperson.try(:insightly_api_key) }

  searchable do
    text :name, :email, :first_name, :last_name,
         :company, :twitter

    string :last_name
    string :salesperson_name
    string(:store_name) { |q| q.store.try(:name) }
    string :name
    integer :id
    time :valid_until_date
    time :estimated_delivery_date
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

  belongs_to_user_called :salesperson
  belongs_to_user_called :insightly_whos_responsible
  belongs_to :store
  has_many :email_templates
  has_many :emails, as: :emailable, dependent: :destroy
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
  validates :salesperson_id, presence: true
  validates :store, presence: true
  validates :valid_until_date, presence: true
  validates(*(INSIGHTLY_FIELDS - [:insightly_opportunity_id]), presence: true, if: :should_validate_insightly_fields?)
  validate :no_line_item_errors

  after_save :set_quote_request_statuses_to_quoted
  after_create :enqueue_create_freshdesk_ticket
  after_create :enqueue_create_insightly_opportunity
  after_initialize :set_default_valid_until_date
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
      ) OR
      (
        activities.trackable_type = "Comment" AND activities.trackable_id IN (?)
      ) OR
      (
        activities.trackable_type = "Job" AND activities.trackable_id IN (?)
      )
    ', *([self.class.name, id] * 2 + [comments.map(&:id), jobs.map(&:id)]) ).order('activities.created_at DESC')
  end

  def show_quoted_email_text
    Nokogiri::HTML()
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

  def salesperson_name
    salesperson.try(:last_name)
  end

  def no_ticket_id_entered?
    freshdesk_ticket_id.blank?
  end

  def no_fd_login?(current_user)
    config = FreshdeskModule.get_freshdesk_config(current_user)
    return true if config.nil?

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
    Rails.cache.fetch(:quote_fd_ticket, :expires => 15.minutes) do
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

  # This is needed to trick the 'fields_for' view helper
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

    new_job = Job.new
    new_job.name        = imprintable_group.name
    new_job.description = imprintable_group.description
    new_job.save!

    new_line_items = Imprintable::TIERS.keys.map do |tier|
      imprintable = imprintable_group.default_imprintable_for_tier(tier)

      next if imprintable.nil?

      line_item = LineItem.new
      line_item.quantity           = quantity
      line_item.decoration_price   = decoration_price
      line_item.imprintable_price  = imprintable.base_price || 0
      line_item.imprintable_object = imprintable
      line_item.job                = new_job
      line_item.tier               = tier

      line_item
    end
      .compact

    new_line_items.each(&:save!)
    @group_added_id = new_job.id

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

    @imprintable_line_item_added_ids = []
    # TODO error or something if attrs[:imprintables] is nil
    attrs[:imprintables].map do |imprintable_id|
      imprintable = Imprintable.find imprintable_id

      line_item = LineItem.new
      line_item.job                = job
      line_item.tier               = attrs[:tier].blank? ? Imprintable::TIER.good : attrs[:tier]
      line_item.quantity           = attrs[:quantity].blank? ? 1 : attrs[:quantity]
      line_item.decoration_price   = attrs[:decoration_price].blank? ? 0 : attrs[:decoration_price]
      line_item.imprintable_price  = imprintable.base_price
      line_item.imprintable_object = imprintable

      if line_item.save
        @imprintable_line_item_added_ids << line_item.id
      else
        @line_item_errors ||= {}
        @line_item_errors[line_item.imprintable.name] = line_item.errors.full_messages
      end
    end
  end

  def should_validate_insightly_fields?
    should_access_third_parties? && salesperson_has_insightly? && insightly_opportunity_id.blank?
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

    self.email               ||= quote_request.email
    self.qty                 ||= quote_request.approx_quantity
    self.phone_number        ||= quote_request.phone_number if quote_request.phone_number
    self.company             ||= quote_request.organization if quote_request.organization
    self.quote_source        ||= 'Online Form'
    self.freshdesk_ticket_id ||= quote_request.freshdesk_ticket_id

    if quote_request.date_needed
      self.deadline_is_specified = true
      self.valid_until_date = quote_request.date_needed
    end

    self.estimated_delivery_date = nil
  end

  def enqueue_create_freshdesk_ticket
    self.delay(queue: 'api').create_freshdesk_ticket if should_access_third_parties?
  end
  warn_on_failure_of :enqueue_create_freshdesk_ticket

  def create_freshdesk_ticket
    return if freshdesk.nil? || !freshdesk_ticket_id.blank?

    if quote_requests.where.not(freshdesk_contact_id: nil).empty?
      requester_info = {
        email: email,
        phone: format_phone(phone_number),
        name: full_name
      }
    else
      requester_info = {
        requester_id: quote_requests.where.not(freshdesk_contact_id: nil).first.freshdesk_contact_id
      }
    end

    ticket = JSON.parse(freshdesk.post_tickets(
        helpdesk_ticket: {
          source: 2,
          group_id: freshdesk_group_id(salesperson),
          ticket_type: 'Lead',
          subject: "Your Quote \"#{self.name}\" (##{self.id}) from the #{salesperson.store.try(:name) || 'Ann Arbor T-shirt Company'}",
          custom_field: { FD_QUOTE_ID_FIELD => id },
          description_html: freshdesk_description(quote_requests)
        }
         .merge(requester_info)
      ))
      .try(:[], 'helpdesk_ticket')

    self.freshdesk_ticket_id = ticket.try(:[], 'display_id')
    save(validate: false)
    ticket
  end
  warn_on_failure_of :create_freshdesk_ticket, raise_anyway: true

  # NOTE this is unused (but reserved in case it seems handy)
  def fetch_freshdesk_ticket(from_email = 'crm@softwearcrm.com')
    begin
      tickets = JSON.parse(freshdesk.get_tickets(
        email: from_email,
        filter_name: 'all_tickets'
      ))
      # We only get a hash on error... better way to check?
      return if tickets.is_a?(Hash)

      ticket = tickets.find do |t|
        doc = Nokogiri::XML(t['description_html'])
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

      _response = freshdesk.put_tickets(
        id: freshdesk_ticket_id,
        helpdesk_ticket: {
          requester_id: contact_id,
          source: 2,
          group_id: freshdesk_group_id(salesperson),
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
    self.delay(queue: 'api').create_insightly_opportunity if should_access_third_parties?
  end
  warn_on_failure_of :enqueue_create_insightly_opportunity

  def create_insightly_opportunity
    return if insightly.nil? || !insightly_opportunity_id.blank?

    unless insightly_whos_responsible_id.nil?
      /(?<name_part>[\w\.-]+)@/ =~ insightly_whos_responsible.email
      unless name_part.nil?
        responsible_user = insightly.get_users(
          '$filter' => "startswith(EMAIL_ADDRESS, '#{name_part}')"
        ).first
      end
    end

    Rails.logger.error "INSIGHTLYOP START creating insightly opportunity with name #{name}"
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
        .merge(responsible_user ? { responsible_user_id: responsible_user.user_id } : {})
    )
    self.insightly_opportunity_id = op.opportunity_id
    save(validate: false)
    Rails.logger.error "INSIGHTLYOP END creating insightly opportunity with name #{name}"
    op
  end
  warn_on_failure_of :create_insightly_opportunity, raise_anyway: true

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

=begin
 Here are the field names as of june 4 2015:

  OPPORTUNITY_FIELD_3: Did the Customer Request a Specific Deadline? (DROPDOWN)
  OPPORTUNITY_FIELD_5: Did the Customer Request a Rush Deadline? (DROPDOWN)
  OPPORTUNITY_FIELD_1: Hard Deadline is... (DATE)
  OPPORTUNITY_FIELD_2: QTY (TEXT)
  OPPORTUNITY_FIELD_12: Categories/Profile (Use) (DROPDOWN)
  OPPORTUNITY_FIELD_10: Source of Lead (DROPDOWN)
  OPPORTUNITY_FIELD_11: Bid Amount Tier (DROPDOWN)

 Run `bundle exec rake insightly:custom_fields` to generate this list
=end
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
    if deadline_is_specified?
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
    line_items.where(imprintable_object_id: nil)
  end

  def activity_parameters_hash_for_job_changes(job, li_old, imprints_old)
    # Add your line items to your hash
    hash = {}
    hash[:line_items] = {}
    hash[:imprints] = {}
    hash[:group_id] = job.id

    job.line_items.each do |li|
      hash[:line_items][li.id] = {}
      lo = li_old.try(:find) { |l| l.id == li.id }
      next if lo.nil?
      if li.quantity != lo.quantity
        hash[:line_items][li.id][:quantity] = {}
        hash[:line_items][li.id][:quantity][:old] = lo.quantity
        hash[:line_items][li.id][:quantity][:new] = li.quantity
      end
      if li.decoration_price != lo.decoration_price
        hash[:line_items][li.id][:decoration_price] = {}
        hash[:line_items][li.id][:decoration_price][:old] = lo.decoration_price.to_f
        hash[:line_items][li.id][:decoration_price][:new] = li.decoration_price.to_f
      end
      if li.imprintable_price != lo.imprintable_price
        hash[:line_items][li.id][:imprintable_price] = {}
        hash[:line_items][li.id][:imprintable_price][:old] = lo.imprintable_price.to_f
        hash[:line_items][li.id][:imprintable_price][:new] = li.imprintable_price.to_f
      end
      if !li.imprintable? && li.unit_price != lo.unit_price
        hash[:line_items][li.id][:unit_price] = {}
        hash[:line_items][li.id][:unit_price][:old] = lo.unit_price.to_f
        hash[:line_items][li.id][:unit_price][:new] = li.unit_price.to_f
      end
    end

    # add your imprints
    job.imprints.each do |i|
      io = imprints_old.try(:find) { |imp| imp.id == i.id }
      next if io.nil?
      hash[:imprints][i.id] = {:old => {}, :new => {}}
      if i.description != io.description
        hash[:imprints][i.id][:old][:description] = io.description
        hash[:imprints][i.id][:new][:description] = i.description
      end
      if i.print_location_id != io.print_location_id
        hash[:imprints][i.id][:old][:print_location_id] = io.print_location_id
        hash[:imprints][i.id][:new][:print_location_id] = i.print_location_id
      end
    end

    # Did name or description change?
    if job.name_changed?
      hash[:name] = {}
      hash[:name][:old] = job.name_was
      hash[:name][:new] = job.name
    end
    if job.description_changed?
      hash[:description] = {}
      hash[:description][:old] = job.description_was
      hash[:description][:new] = job.description
    end
    hash
  end

  def activity_key
   if @group_added_id
    return 'quote.added_line_item_group'
   elsif @imprintable_line_item_added_ids
    return 'quote.added_an_imprintable'
   else
    return 'quote.update'
   end
  end

  def activity_parameters_hash
    hash = {}
    if @group_added_id
      # populate hash with ALL the info for the group
      hash[:imprintables] = {}
      hash[:imprints] = {}
      job = Job.find(@group_added_id)
      job.line_items.each do |li|
        hash[:imprintables][li.id] = li.imprintable.base_price.to_f
      end
      job.imprints.each do |im|
        hash[:imprints][im.id] = im.description
      end
      hash[:name] = job.name
      hash[:id] = job.id
      hash[:decoration_price] = job.line_items.first.decoration_price.to_f
      hash[:quantity] = job.line_items.first.quantity
    elsif @imprintable_line_item_added_ids
      hash[:imprintables] = {}
      @imprintable_line_item_added_ids.each do |li|
        hash[:imprintables][li] = {}
        line_item = LineItem.find(li)
        hash[:imprintables][li][:imprintable_price] = line_item.imprintable_price.to_f
        hash[:imprintables][li][:imprintable_id] = line_item.imprintable_id
        hash[:decoration_price] = line_item.decoration_price.to_f
        hash[:quantity] = line_item.quantity
        hash[:tier] = line_item.tier
        hash[:group_id] = line_item.job_id
      end
    else
      changed_attrs = self.attribute_names.select{ | attr| self.send("#{attr}_changed?")}
      changed_attrs.each do |attr|
      hash[attr] = {
        "old" => self.send("#{attr}_was"), # self.name_was , # self.name_was
        "new" => self.send("#{attr}")  # self.name
      }
      end
    end
   hash
  end

  private

  def no_line_item_errors
    return if @line_item_errors.blank?

    @line_item_errors.each do |name, li_errors|
      errors.add(:line_items, li_errors)
    end

    @line_item_errors = nil
  end

  def freshdesk_contact_id
    quote_requests
      .where("freshdesk_contact_id <> ''")
      .pluck(:freshdesk_contact_id)
      .first
  end

  def set_default_valid_until_date
    self.valid_until_date ||= 30.days.from_now
    self.estimated_delivery_date ||= 14.days.from_now
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
