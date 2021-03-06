require 'active_resource'

module Production
  class StageForPickupTrain < ActiveResource::Base
    include RemoteModel
    self.api_settings_slug = :softwear_production

    belongs_to :order, class_name: 'Production::Order'
  end
end
