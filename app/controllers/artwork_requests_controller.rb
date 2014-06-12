class ArtworkRequestsController < InheritedResources::Base

  def update
    super do |success, failure|
      success.html { redirect_to artwork_requests_path }
      failure.html { render action: :edit }
    end
  end


  def show
    super do |format|
      format.html { redirect_to edit_artwork_request_path params[:id] }
    end
  end

  private

  def permitted_params
    params.permit(artwork_request: [:text, :artist_id, :imprint_method_id, :print_location_id, :salesperson_id, ink_colors_attributes: [:name, :imprint_method_id, :id, :_destroy], jobs_attributes: [:name, :description, :id, :_destroy]])
  end
end