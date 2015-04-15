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
    referred_to_design_studio
  )

  belongs_to :salesperson, class_name: User
  has_many :quote_request_quotes
  has_many :quotes, through: :quote_request_quotes
  has_many :orders, through: :quotes

  validates :name, :email, :description, :source, presence: true
  validates :reason, presence: true, if: :reason_needed?

  before_validation(on: :create) { self.status = 'pending' if status.nil? }
  before_save :link_integrated_crm_contacts_when_assigned

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

  def linked_with_insightly?
    !insightly_contact_id.nil?
  end

  def link_with_insightly!
    return if insightly.nil?

    contact = insightly.get_contacts(email: email).first
    if contact.nil?
      /(?<first_name>^\w+)\s+(?<last_name>.*)/ =~ name

      contact = insightly.create_contact(
        first_name:   first_name,
        last_name:    last_name,
        contactinfos: insightly_contactinfos
      )
    end
    self.insightly_contact_id = contact.contact_id if contact
  end

  def insightly_contactinfos
    infos = []
    infos << { type: 'EMAIL', detail: email }        if email
    infos << { type: 'PHONE', detail: phone_number } if phone_number
    infos
  end

  private

  def link_integrated_crm_contacts_when_assigned
    return unless status == 'assigned'

    link_with_insightly! unless linked_with_insightly?
  end

  def insightly
    @insightly ||= Insightly2::Client.new(Setting.insightly_api_key)
  end
end
