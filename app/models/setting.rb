class Setting < ActiveRecord::Base
  acts_as_paranoid

  attr_encrypted :val, key: 'h4rdc0ded1337ness', if: :encrypted?

  def self.insightly_api_key
    Setting.find_or_create_by(name: 'insightly_api_key').try(:val) ||
      Figaro.env['insightly_api_key'] ||
      create_and_save_insightly_api_key
  end

  def self.get_freshdesk_settings
    freshdesk_records = {
      freshdesk_url: Setting.find_or_create_by(name: 'freshdesk_url').try(:val),
      freshdesk_email: Setting.find_or_create_by(name: 'freshdesk_email').try(:val),
      freshdesk_password: Setting.find_or_create_by(name: 'freshdesk_password').try(:val)
    }
    freshdesk_ymls = {
      freshdesk_url: Figaro.env['freshdesk_url'],
      freshdesk_email: Figaro.env['freshdesk_email'],
      freshdesk_password: Figaro.env['freshdesk_password']
    }

    if configured?(freshdesk_records)
      return freshdesk_records
    elsif configured?(freshdesk_ymls)
      # TODO: create Settings records with environment variables here to use in your form
      Setting.create_and_save_fd_settings(freshdesk_ymls[:freshdesk_url],
                                          freshdesk_ymls[:freshdesk_email],
                                          freshdesk_ymls[:freshdesk_password])
      return freshdesk_ymls
    else
      Setting.create_and_save_fd_settings(nil, nil, nil)
      return nil
    end
  end

  %w(
    payflow_login payflow_password paypal_username paypal_password paypal_signature
    payment_logo_url
  ).each do |method_name|
    define_singleton_method method_name do
      if (setting = Setting.where(name: method_name)).exists?
        return setting.first.val
      else
        Setting.create(
          name:      method_name,
          val:       nil,
          encrypted: /password|signature/ =~ method_name
        ).val
      end
    end
  end

  def self.default_sales_tax_rate
    (
        Setting.find_by(name: 'default_sales_tax_rate') || Setting.create(
          name: 'default_sales_tax_rate',
          val:  '0.06',
          encrypted: false
        )
    )
      .val.to_f
  end

private

  def self.configured?(records)
    records.values.all?
  end

  def self.create_and_save_insightly_api_key
    return if Setting.where(name: 'insightly_api_key').exists?

    Setting.transaction do
      Setting.create(name: 'insightly_api_key', val: nil, encrypted: false)
    end

    nil
  end

  def self.create_and_save_fd_settings(url, email, password)
    url_setting = Setting.create(name: 'freshdesk_url', val: url, encrypted: false)
    email_setting = Setting.create(name: 'freshdesk_email', val: email, encrypted: false)
    password_setting = Setting.create(name: 'freshdesk_password', val: password, encrypted: true)

    Setting.transaction do
      # If the db messes up and saving any one of these fails
      # (even without validation) then none of the records should be saved,
      # hence the transaction
      url_setting.save(validate: false)
      email_setting.save(validate: false)
      password_setting.save(validate: false)
    end

    return {
             freshdesk_url: url_setting,
             freshdesk_email: email_setting,
             freshdesk_password: password_setting
           }
  end
end
