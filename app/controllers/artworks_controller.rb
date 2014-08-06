class ArtworksController < InheritedResources::Base

  respond_to :js

  def index
    super do |format|
      @artworks = Artwork.all.page(params[:page])
      @artwork_request = params[:artwork_request_id].nil? ? nil : ArtworkRequest.find(params[:artwork_request_id])

      format.js{ render(locals: { artwork_request: @artwork_request }) }
    end
  end

  def self.permitted_search_locals
    [:artwork_request_id]
  end

  def self.transform_search_locals(locals)
    locals[:artwork_request_id].empty? ? {} : { artwork_request: ArtworkRequest.find(locals[:artwork_request_id]) }
  end

  private

  def permitted_params
    params.permit(:artwork_request_id, :artworks,
                  artwork: [
                    :id, :name, :description, :tag_list, :artist_id,
                    artwork_request_ids: [],
                    artwork_attributes: [
                      :file, :description, :id, :_destroy
                    ],
                    preview_attributes: [
                      :file, :description, :id, :_destroy
                    ]
                  ])
  end
end
