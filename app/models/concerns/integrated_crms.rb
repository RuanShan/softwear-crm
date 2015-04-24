module IntegratedCrms
  extend ActiveSupport::Concern

  included do
    def self.get_insightly_api_key_from(&block)
      @@insightly_api_key_source = block
    end
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
end
