class FreshdeskDrop < Liquid::Drop
  def get_contact(freshdesk_id)
    config = Setting.get_freshdesk_settings
    if config[:freshdesk_email].blank? || config[:freshdesk_password].blank?
      raise 'User freshdesk information isn\'t configured'
    end
    page = 1
    response = FreshdeskModule.get_contacts(page, config[:freshdesk_email], config[:freshdesk_password])
    while response != []
      raise 'freshdesk configuration is invalid' if response.class == Hash

      response.each do |user|
        if user['user']['id'] == freshdesk_id
          return user
        end
      end

      page += 1
      response = FreshdeskModule.get_contacts(page, config[:freshdesk_email], config[:freshdesk_password])
    end
  end
end
