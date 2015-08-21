module Api
  class ImprintsController < Softwear::Lib::ApiController
    private

    def includes
      [
        proofs: {
          methods: [
            :artwork_paths, :artwork_thumbnail_paths,
            :mockup_paths, :mockup_thumbnail_paths
          ]
        }
      ]
    end
  end
end
