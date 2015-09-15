require 'active_resource'

module Production
  class Imprint < ActiveResource::Base
    include RemoteModel
    self.api_settings_slug = :softwear_production

    belongs_to :job, class_name: 'Production::Job'
  end
end
