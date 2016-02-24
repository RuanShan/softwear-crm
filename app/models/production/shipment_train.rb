require 'active_resource'

module Production
  class ShipmentTrain < ActiveResource::Base
    include RemoteModel
    self.api_settings_slug = :softwear_production

    def shipment_holder
      return if shipment_holder_type.blank? || shipment_holder_id.blank?
      @shipment_holder ||= "Production::#{shipment_holder_type}".constantize.find(shipment_holder_id)
    end
  end
end
