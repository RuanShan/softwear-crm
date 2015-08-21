module Api
  class ProofsController < Softwear::Lib::ApiController
    private

    def permitted_attributes
      [
        :artwork_link,
        :artwork_thumbnail_link
      ]
    end
  end
end
