require File.expand_path('../boot', __FILE__)

# Pick the frameworks you want:
require "active_record/railtie"
require "action_controller/railtie"
require "action_mailer/railtie"
require "sprockets/railtie"
require 'csv'
# require "rails/test_unit/railtie"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module CrmSoftwearcrmCom
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    config.time_zone = 'Eastern Time (US & Canada)'
    config.active_record.default_timezone = :utc

    # Autoload lib/ folder including all subdirectories
    config.autoload_paths += Dir["#{config.root}/lib/**/"]

    # add customer validators path
    config.autoload_paths += %W["#{config.root}/app/validators/"]

    # This will be default in Rails 5.
    config.active_record.raise_in_transactional_callbacks = true

    delivery_method = ENV['action_mailer_delivery_method']
    if delivery_method == 'smtp'
      smtp_settings = {}
      config.action_mailer.delivery_method = :smtp
      smtp_settings[:address] = ENV['smtp_address'] unless !ENV.key? 'smtp_address'
      smtp_settings[:port] = ENV['smtp_port'] unless !ENV.key? 'smtp_port'
      smtp_settings[:domain] = ENV['smtp_domain'] unless !ENV.key? 'smtp_domain'
      smtp_settings[:user_name] = ENV['smtp_user_name'] unless !ENV.key? 'smtp_user_name'
      smtp_settings[:password] = ENV['smtp_password'] unless !ENV.key? 'smtp_password'
      smtp_settings[:authentication] = ENV['smtp_authentication'] unless !ENV.key? 'smtp_authentication'
      smtp_settings[:enable_starttls_auto] = ENV['smtp_enable_starttls_auto'] unless !ENV.key? 'smtp_enable_starttls_auto'
      config.action_mailer.smtp_settings = smtp_settings
    end

    config.to_prepare do
      [
        Devise::SessionsController,
        Devise::PasswordsController
      ].each { |c| c.layout 'no_overlay' }
    end

    unless ENV['aws_secret_access_key'].nil? && ENV['aws_access_key_id'].nil? && ENV['aws_bucket'].nil?
      config.paperclip_defaults = {
          storage: :s3,
          s3_credentials: {
              bucket: ENV['aws_bucket'],
              access_key_id: ENV['aws_access_key_id'],
              secret_access_key: ENV['aws_secret_access_key']
          }
      }
    end

  end
end
