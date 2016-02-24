require 'active_resource'

module Production
  class ImprintGroup < ActiveResource::Base
    include RemoteModel
    self.api_settings_slug = :softwear_production

    has_many :imprints, class_name: 'Production::Imprint'
  end
end
