module Api
  class OrdersController < Softwear::Lib::ApiController
    private

    def permitted_attributes
      super
    end

    def includes
      [
        proofs: {
          include: {
            artworks: {
              methods: [
                :path, :thumbnail_path
              ]
            }
          },
          methods: [
            :mockup_paths
          ]
        }
      ]
    end
  end
end
