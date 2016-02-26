require 'sidekiq'
require 'sidekiq-status'

redis_url = "#{Figaro.env.redis_path}/#{Figaro.env.redis_db || 0}"

Sidekiq.configure_client do |config|
  config.client_middleware do |chain|
    chain.add Sidekiq::Status::ClientMiddleware
  end
  config.redis = { namespace: 'softwear-crm', url: redis_url, network_timeout: 10 }
end

Sidekiq.configure_server do |config|
  config.server_middleware do |chain|
    chain.add Sidekiq::Status::ServerMiddleware, expiration: 30.minutes # default
  end
  config.redis = { namespace: 'softwear-crm', url: redis_url }
end

# The EC2 load balancer accepts https requests, then forwards them via http. This pisses
# off rack-protection.
module Rack
  module Protection
    class HttpOrigin < Base
      def accepts?(_env)
        true
      end
    end
  end
end
