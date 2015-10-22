class ArtworksController < InheritedResources::Base
  before_action :set_current_action

  respond_to :html, :js

  def index
    super do |format|
      @artworks = Artwork.all.page(params[:page])
      @artwork_request = params[:artwork_request_id].nil? ? nil : ArtworkRequest.find(params[:artwork_request_id])

      format.js{ render(locals: { artwork_request: @artwork_request }) }
      format.html{ render(locals: { artwork_request: @artwork_request }) }
    end
  end

  def create
    super do |success, failure|
      success.html { redirect_to params[:back_to].blank? ? artworks_path : params[:back_to] }
      failure.html { render :new }
    end
  end

  def update
    super do |format|
      format.html { redirect_to params[:back_to].blank? ? artworks_path : params[:back_to] }
    end
  end

  def self.permitted_search_locals
    [:artwork_request_id]
  end

  def self.transform_search_locals(locals)
    locals[:artwork_request_id].empty? ? {} : { artwork_request: ArtworkRequest.find(locals[:artwork_request_id]) }
  end

  protected

  def set_current_action
    @current_action = 'artworks'
  end

  private

  def permitted_params
    params.permit(:artwork_request_id, :artworks,
                  artwork: [
                    :id, :name, :description, :tag_list, :artist_id,
                    :local_file_location, :bg_color,
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
