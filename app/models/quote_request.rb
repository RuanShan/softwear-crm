class QuoteRequest < ActiveRecord::Base
  include TrackingHelpers

  tracked by_current_user + { parameters: { s: ->(_c, r) { r.track_state_changes } } }

  default_scope { order('quote_requests.created_at DESC') }

  paginates_per 50

  searchable do
    text :name, :email, :description, :source, :status
    text :salesperson do
      salesperson.try(:name)
    end

    string :status
  end

  QUOTE_REQUEST_STATUSES = %w(
    assigned pending quoted requested_info could_not_quote
    referred_to_design_studio duplicate
  )

  belongs_to :salesperson, class_name: User
  has_many :quote_request_quotes
  has_many :quotes, through: :quote_request_quotes
  has_many :orders, through: :quotes

  validates :name, :email, :description, :source, presence: true
  validates :reason, presence: true, if: :reason_needed?

  before_validation(on: :create) { self.status = 'pending' if status.nil? }
  before_create :link_integrated_crm_contacts

  def self.of_interest
    where.not status: 'could_not_quote'
  end

  def salesperson_id=(id)
    super
    self.status = 'assigned'
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

  def link_with_insightly!
    return if insightly.nil?
    begin
      contact = insightly.get_contacts(email: email).first
      if contact.nil?
        unless /(?<first_name>^\w+)\s+(?<last_name>.*)/ =~ name
          first_name = name
        end

        if organization
          org = insightly.get_organisations
            .find { |o| o.organisation_name.downcase == organization.downcase } ||
            insightly.create_organisation(
              organisation: {
                organisation_name: organization
              }
            )
          insightly_organisation_id = org.try(:organisation_id)
        end

        contact = insightly.create_contact(contact: {
          first_name:   first_name,
          last_name:    last_name,
          contactinfos: insightly_contactinfos,
          links: [({ organisation_id: org.organisation_id } if org)].compact
        })
      end

      if contact
        self.insightly_contact_id = contact.contact_id
        logger.info "Set Quote Request Insightly contact to #{insightly_contact_id}"
      end

    rescue Insightly2::Errors::ClientError
      logger.error "(QUOTE REQUEST) Bad Insightly API Key in settings"
    end
  end

  def insightly_contactinfos
    infos = []
    infos << { type: 'EMAIL', detail: email }        if email
    infos << { type: 'PHONE', detail: phone_number } if phone_number
    infos
  end

  def link_with_freshdesk!
    return if freshdesk.nil?
    begin
      user = JSON.parse(freshdesk.get_users(query: "email is #{email}"))
        .first
        .try(:[], 'user')

      if user.nil?
        if organization
          # NOTE Freshdesk calls them "companies" externally, and
          # "customers" externally. Awesome, right?
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
          phone: phone_number,
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
      logger.error "(QUOTE REQUEST - FRESHDESK) #{e.message}"
      e
    end
  end

  def linked_with_freshdesk?
    !freshdesk_contact_id.nil?
  end

  private

  def link_integrated_crm_contacts
    link_with_insightly! unless linked_with_insightly?
    link_with_freshdesk! unless linked_with_freshdesk?
  end

  def insightly
    api_key = Setting.insightly_api_key
    return (@insightly = nil) if api_key.nil? || api_key.empty?
    @insightly ||= Insightly2::Client.new(api_key)
  end

  def freshdesk
    @freshdesk ||= (
      settings = Setting.get_freshdesk_settings
      if settings.nil?
        nil
      else
        Freshdesk.new(
          settings[:freshdesk_url],
          settings[:freshdesk_email],
          settings[:freshdesk_password]
        )
        .tap { |fd| fd.response_format = 'json' }
      end
    )
  end
end
