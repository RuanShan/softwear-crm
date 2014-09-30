require 'rest_client'
module FreshdeskModule
  def get_freshdesk_config(current_user)
    settings = Setting.get_freshdesk_settings
    if user_configured? current_user
      settings[:freshdesk_email] = current_user.email
      settings[:freshdesk_password] = current_user.password
    end
    settings
  end

  def open_connection(config)
    Freshdesk.new(config[:freshdesk_url], config[:freshdesk_email], config[:freshdesk_password])
  end

# returns either nil if no customer is found,
# or a hash comtaining the customer's information
  def get_customer(config, email)
    params = URI.escape("query=email is #{email}")
    site = RestClient::Resource.new("#{ config[:freshdesk_url] }/contacts.json?state=all&#{params}", config[:freshdesk_email], config[:freshdesk_password])

    response = site.get(accept: 'application/json')
    ary = JSON.parse(response.body)

    ary.blank? ? nil : ary.first
  end

private

  def user_configured?(current_user)
    current_user.freshdesk_password.blank? || current_user.freshdesk_email.blank? ? false : true
  end

end