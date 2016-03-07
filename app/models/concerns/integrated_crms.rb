module IntegratedCrms
  extend ActiveSupport::Concern

  FD_QUOTE_ID_FIELD = :softwearcrm_quote_id_7483
  FD_NO_OF_DECORATIONS_FIELD = :cf_of_unique_decorations_in_pr_7483
  FD_NO_OF_PROOFS = :cf_of_proofs_for_pr_7483
  FD_PROOF_ARTWORK_FOLDER = :order_folder_7483
  FD_PROOF_CREATION_STATUS = :custom_proof_creation_status_7483
  FD_ORDER_QTY = :order_qty_7483
  FD_ART_GROUP_ID = 86612

  included do
    def self.get_insightly_api_key_from(&block)
      @@insightly_api_key_source = block
    end
  end

  def should_access_third_parties?
    Rails.env.production? || Figaro.env.integrated_crms.try(:downcase) == 'true'
  end

  def insightly
    raise "Set insightly api key with `set_insightly_api_key` in class "\
          "definition." if @@insightly_api_key_source.nil?
    api_key = instance_eval(&@@insightly_api_key_source)
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

  def create_insightly_contact(attrs_or_object)
    if attrs_or_object.is_a?(Hash)
      missing_keys = [:first_name, :email, :phone_number] - attrs_or_object.keys
      unless missing_keys.empty?
        raise "Missing keys for insightly contact: #{missing_keys.join(', ')}"
      end
      object = OpenStruct.new(attrs_or_object)
    else
      object = attrs_or_object
    end

    begin
      contact = insightly.get_contacts(email: object.email).first
      if contact.nil?
        if object.try(:organization)
          org = insightly.get_organisations
            .find { |o| o.organisation_name.downcase == object.organization.downcase } ||
            insightly.create_organisation(
              organisation: {
                organisation_name: object.organization
              }
            )
        end

        contact = insightly.create_contact(contact: {
          first_name:   object.first_name,
          last_name:    object.try(:last_name),
          contactinfos: insightly_contactinfos(object),
          links: [({ organisation_id: org.organisation_id } if org)].compact
        })
      end

      contact
    rescue Insightly2::Errors::ClientError
      logger.error "Bad Insightly API Key in settings"
      nil
    rescue StandardError => e
      logger.error "ERROR CREATING INSIGHTLY CONTACT: #{e.class}: #{e.message}"
      nil
    end
  end

  def insightly_contactinfos(obj)
    infos = []
    infos << { type: 'EMAIL', detail: obj.email }        if obj.try(:email)
    infos << { type: 'PHONE', detail: obj.phone_number } if obj.try(:phone_number)
    infos
  end

  def freshdesk_group_id(user)
    store_name = user.store.try(:name).try(:downcase) || ''
    if store_name.include? 'ypsi'
      86317 # Group ID of Sales - Ypsilanti within Freshdesk
    else
      86316 # Group ID of Sales - Ann Arbor within Freshdesk
    end
  end

  def freshdesk_department(user)
    store_name = user.store.try(:name).try(:downcase) || ''
    if store_name.include? 'arbor'
      'Sales - Ann Arbor'
    elsif store_name.include? 'ypsi'
      'Sales - Ypsilanti'
    end
  end

  def freshdesk_description(quote_request)
    if quote_request.respond_to?(:reduce)
      quote_requests = quote_request
    else
      quote_requests = [quote_request]
    end

    r = ApplicationController.new
    quote_requests
      .reduce('') do |description, qr|
        r.render_string(
          template: nil,
          partial: 'quote_requests/basic_table',
          locals: { quote_request: qr }
        )
      end
      .html_safe
  end

  def freshdesk_ticket_link(obj = nil)
    obj ||= self
    return if obj.try(:freshdesk_ticket_id).blank?
    "https://annarbortees.freshdesk.com/helpdesk/tickets/#{freshdesk_ticket_id}"
  end

  def format_phone(num)
    return if num.nil?

    num.gsub!(/\D/, '')

    if num.length == 11 && num[0] == '1'
      num
    elsif num.length == 10
      num = '1' + num
    elsif num.length >= 7 && num.length <= 9
      dif = num.length - 7
      if dif != 0
        num = num.slice(dif, 7)
      end
      num = '1734' + num
    end

    "+#{num.slice(0, 1)}-#{num.slice(1, 3)}-#{num.slice(4, 3)}-#{num.slice(7, 4)}"
  end
end
