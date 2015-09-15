require 'active_resource'

module Production
  class Job < ActiveResource::Base
    include RemoteModel
    self.api_settings_slug = :softwear_production

    has_many :imprints, class_name: 'Production::Imprint'
    belongs_to :order, class_name: 'Production::Order'
  end
end
