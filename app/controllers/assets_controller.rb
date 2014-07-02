class AssetsController < InheritedResources::Base
  respond_to :js

  # def destroy
  #   @artwork_request = ArtworkRequest.find(params[:id])
  #   respond_to do |format|
  #     format.js
  #   end
  #   @artwork_request.destroy
  # end
end
