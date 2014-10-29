require 'rest_client'

module FreshdeskModule
  def self.get_freshdesk_config(current_user)
    settings = Setting.get_freshdesk_settings
    if user_configured? current_user
      settings[:freshdesk_email] = current_user.freshdesk_email
      settings[:freshdesk_password] = current_user.freshdesk_password
    end
    settings
  end

  def self.open_connection(config)
    client = Freshdesk.new(config[:freshdesk_url], config[:freshdesk_email], config[:freshdesk_password])
    client.response_format = 'json'
    client
  end

  def self.send_ticket(client, config, quote)
    freshdesk_info = fetch_data_to_h(client, config, quote)

    client.post_tickets(
        email: email,
        requester_id: freshdesk_info[:requester_id],
        requester_name: freshdesk_info[:requester_name],
        source: 2,
        group_id: freshdesk_info[:group_id],
        ticket_type: 'Lead',
        subject: 'Created by Softwear-CRM',
        custom_field: { department_7483: freshdesk_info[:department] }
    )
  end

private

  def self.user_configured?(current_user)
    current_user.freshdesk_password.blank? || current_user.freshdesk_email.blank? ? false : true
  end

  def self.fetch_data_to_h(client, config, quote)
    freshdesk_info = {}
    freshdesk_info = fetch_group_id_and_dept(freshdesk_info)
    fetch_requester_id_and_name(freshdesk_info, client, config, quote)
  end

  def self.fetch_group_id_and_dept(old_hash)
    new_hash = {}
    if store.name.downcase.include? 'arbor'
#     Hardcoded id's are the ones freshdesk uses for AA and Ypsi sales dept
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

  def self.fetch_requester_id_and_name(old_hash, client, config, quote)
    customer = create_freshdesk_customer(client, quote)

    new_hash = {}
    if customer.nil?
#     search for customer
      customer = self.search_for_customer(client, quote.first_name)
      if customer.nil?
#       create ticket with no customer
#       create timeline activity saying ticket has no customer
      else
#       create ticket with found customer
      end
    else
#     customer found, create ticket with his credentials
      new_hash[:requester_name] = parsed_json['user']['name']
      new_hash[:requester_id] = parsed_json['user']['id']
    end

    old_hash.merge(new_hash)
  end

  def self.create_freshdesk_customer(client, quote)
    begin
      response = client.post_users(name: "#{quote.first_name} #{quote.last_name}",
                        email: quote.email)
      return JSON.parse(response)
    rescue Freshdesk::AlreadyExistedError
      return nil
    end
  end

  def self.search_for_customer(client, first_name)
#   binary search for a matching customer based on first name
  end
end