class Setting < ActiveRecord::Base
  acts_as_paranoid

  attr_encrypted :value, key: 'h4rdc0ded1337ness', if: :encrypted?
  validates :val, presence: true

  def self.get_freshdesk_settings
    freshdesk_records = {
      freshdesk_url: Setting.find_by(name: 'freshdesk_url'),
      freshdesk_email: Setting.find_by(name: 'freshdesk_email'),
      freshdesk_password: nil
    }
    freshdesk_ymls = {
      freshdesk_url: Figaro.env['freshdesk_url'],
      freshdesk_email: Figaro.env['freshdesk_email'],
      freshdesk_password: Figaro.env['freshdesk_password']
    }

    if configured?(freshdesk_records)
      puts 'this should not print'
      return freshdesk_records
    elsif configured?(freshdesk_ymls)
      # TODO: create Settings records with environment variables here to use in your form
      puts 'this should print'
      return freshdesk_ymls
    else
      {}
    end
  end

private

  def self.configured?(records)
    records.values.all?
  end
end
