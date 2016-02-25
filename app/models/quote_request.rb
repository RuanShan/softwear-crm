class QuoteRequest < ActiveRecord::Base
  include TrackingHelpers
  include IntegratedCrms
  include Softwear::Auth::BelongsToUser
  include Softwear::Lib::Enqueue

  tracked by_current_user + { parameters: { s: ->(_c, r) { r.track_state_changes } } }
  acts_as_warnable
  acts_as_commentable

  get_insightly_api_key_from { Setting.insightly_api_key }

  scope :of_interest, -> { where.not status: 'could_not_quote' }
  scope :assigned, -> { where status: 'assigned' }
  scope :unassigned, -> { where.not status: 'assigned' }
  default_scope { order('quote_requests.created_at DESC') }

  paginates_per 50

  searchable do
    text :name, :email, :description, :source, :status
    text :salesperson do
      salesperson.try(:name)
    end
    integer :salesperson_id

    string :status
    time :created_at
  end

  QUOTE_REQUEST_STATUSES = %w(
    assigned pending quoted requested_info could_not_quote
    referred_to_design_studio duplicate
  )

  belongs_to_user_called :salesperson
  has_many :quote_request_quotes
  has_many :quotes, through: :quote_request_quotes
  has_many :orders, through: :quotes
  has_many :emails, as: :emailable, dependent: :destroy
  has_many :customer_uploads, dependent: :destroy
  has_many :quote_request_imprintables, dependent: :destroy
  has_many :imprintables, through: :quote_request_imprintables

  accepts_nested_attributes_for :customer_uploads

  validates :name, :email, :description, :source, presence: true
  validates :reason, presence: true, if: :reason_needed?

  before_validation(on: :create) { self.status = 'pending' if status.nil? }
  enqueue :link_integrated_crm_contacts, queue: 'api'
  before_create :enqueue_link_integrated_crm_contacts, if: :should_access_third_parties?
  before_save :notify_salesperson_if_assigned
  before_save { self.status = 'assigned' if salesperson_id_changed? && salesperson_id_was.nil? }

  def send_assigned_email(user_id)
    return if user_id != salesperson_id || salesperson_id.nil?
    QuoteRequestMailer.notify_salesperson_of_quote_request_assignment(self).deliver
  end

  def imprintable_quantities
    Hash[
      quote_request_imprintables.map do |qri|
        [qri.imprintable_id, qri.quantity]
      end
    ]
  end

  def imprintable_quantities=(value)
    return if value.blank?
    if value.is_a?(String)
      hash = JSON.parse(value.gsub('&quot;', '"'))
    elsif value.is_a?(Hash)
      hash = value
    else
      raise "Expected hash or string for QuoteRequest#imprintable_quantities=, got #{value.inspect}"
    end

    hash.each do |imprintable_id, quantity|
      next if quantity.to_i == 0

      quote_request_imprintables.build(
        imprintable_id: imprintable_id,
        quantity:       quantity.to_i
      )
    end
  end

  def assigned?
    status == 'assigned'
  end
  def unassigned?
    status != 'assigned'
  end

  def others_with_same_status
    QuoteRequest.where(salesperson_id: salesperson_id)
  end
  def next
    @next ||= others_with_same_status.where('id < ?', id).order(id: :desc).first
  end
  def previous
    @previous ||= others_with_same_status.where('id > ?', id).order(id: :asc).first
  end

  def reason_needed?
    status == 'could_not_quote'
  end

  def status=(new_status)
    @old_status = status
    super(new_status)
  end

  def track_state_changes
    if status != @old_status
      {
        status_changed_from: @old_status,
        status_changed_to: status
      }
    else
      {}
    end
  end

  def insightly_contact_url
    return nil if insightly_contact_id.nil?
    "https://googleapps.insight.ly/Contacts/Details/#{insightly_contact_id}"
  end

  def freshdesk_contact_url
    return nil if freshdesk_contact_id.nil?
    "http://annarbortees.freshdesk.com/contacts/#{freshdesk_contact_id}"
  end

  def linked_with_insightly?
    !insightly_contact_id.nil?
  end

  def first_name
    /(?<first_name>^\w+)/ =~ name
    first_name
  end
  def last_name
    /(?<first_name>^\w+)\s+(?<last_name>.*)/ =~ name
    last_name
  end

  def activity_source(activity)
    "Quote Request" if activity.key.include?('create')
  end

  def link_with_insightly
    return if insightly.nil?

    contact = create_insightly_contact(self)
    if contact
      self.insightly_contact_id = contact.contact_id

      if contact.try(:links).respond_to?(:each)
        contact.links.each do |link|
          if link.key?('organisation_id')
            # TODO Supposed to query for organisation at this point!
            # Or something I actually have no idea.
            # self.organisation_id = link['organisation_id']
            break
          end
        end
      end

      logger.info "Set Quote Request Insightly contact to #{insightly_contact_id}"
    end
  end

  def link_with_freshdesk
    return if freshdesk.nil?
    begin
      user = JSON.parse(freshdesk.get_users(query: "email is #{email}"))
        .first
        .try(:[], 'user')

      if user.nil?
        if organization
          # NOTE Freshdesk calls them "companies" externally, and
          # "customers" internally. Awesome, right?
          comp = JSON.parse(freshdesk.get_companies(
              letter: organization.each_char.next
            ))
            .find { |c| c['customer']['name'].downcase == organization.downcase }

          comp ||= JSON.parse(freshdesk.post_companies(customer: {
              name: organization
            }))
            .try(:[], 'customer')

          freshdesk_company_id = comp.try(:[], 'id')
        end

        user = JSON.parse(freshdesk.post_users(user: {
          name: name,
          email: email,
          phone: format_phone(phone_number),
          customer_id: freshdesk_company_id
        }))
          .try(:[], 'user')
      end

      if user
        self.freshdesk_contact_id = user['id']
      end

    rescue Freshdesk::AlreadyExistedError => e
      logger.error "(QUOTE REQUEST - FRESHDESK) Error adding freshdesk contact"
      e
    rescue Freshdesk::ConnectionError => e
      logger.error "(QUOTE REQUEST - FRESHDESK) #{e.class}: #{e.message}"
      e
    rescue StandardError => e
      logger.error "(QUOTE REQUEST - FRESHDESK) #{e.class}: #{e.message}"
      e
    end
  end

  def create_freshdesk_ticket
    return if freshdesk.nil? || !freshdesk_ticket_id.blank?

    if freshdesk_contact_id.blank?
      requester_info = {
        name: name,
        email: email,
        phone: format_phone(phone_number)
      }
    else
      requester_info = {
        requester_id: freshdesk_contact_id
      }
    end

    ticket = JSON.parse(freshdesk.post_tickets(
        helpdesk_ticket: {
          source: 2,
          group_id: freshdesk_group_id(salesperson),
          ticket_type: 'Lead',
          subject: "Information regarding your quote request (##{id}) from the Ann Arbor T-shirt Company",
          description_html: freshdesk_description(self)
        }
          .merge(requester_info)
      ))
      .try(:[], 'helpdesk_ticket')

    self.freshdesk_ticket_id = ticket['display_id']
    save(validate: false)
    ticket
  end
  warn_on_failure_of :create_freshdesk_ticket, raise_anyway: true unless Rails.env.test?

  def linked_with_freshdesk?
    !freshdesk_contact_id.nil?
  end

  def to_dock
    %i(id name approx_quantity description date_needed)
      .map{|a| { a => self[a] } }
      .reduce({}, :merge)
  end

  def uploaded_file_urls
  end

  private

  def notify_salesperson_if_assigned
    self.send_assigned_email(salesperson_id) if salesperson_id_changed?
  end

  warn_on_failure_of :enqueue_link_integrated_crm_contacts
  warn_on_failure_of :link_with_insightly
  warn_on_failure_of :link_with_freshdesk

  def link_integrated_crm_contacts
    link_with_insightly unless linked_with_insightly?
    link_with_freshdesk unless linked_with_freshdesk?
  end
end
