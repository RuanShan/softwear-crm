require 'active_resource'

module Production
  class Order < ActiveResource::Base
    include RemoteModel
    self.api_settings_slug = :softwear_production
  
  end
end      
