class CustomerUpload < ActiveRecord::Base
  belongs_to :quote_request

  if Figaro.env.www_domain.nil?
    if Rails.env.production?
      raise "Please set `www_domain` environment variable"
    else
      Rails.logger.warn "`www_domain` environment variable not set; "\
                        "customer art links will not work."
    end
  end

  def full_url
    "#{Figaro.env.www_domain}#{url}"
  end
end
