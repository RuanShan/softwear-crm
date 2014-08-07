class ArtworkRequestsController < InheritedResources::Base
  before_filter :format_time, only: [:create, :update]
  before_filter :assign_order

  respond_to :js

  #TODO couldn't figure out a way to refactor this, but could possibly be too much for a controller?
  def update
    unless params[:artwork_id].nil?
      @artwork_request = ArtworkRequest.find(params[:id])
      @artwork = Artwork.find(params[:artwork_id])

      if params[:remove_artwork].nil?
        @artwork_request.artworks << @artwork
        @artwork_request.artwork_status = 'Art Created'
      else
        @artwork_request.artworks.delete(@artwork)
        @artwork_request.artwork_status = 'Pending' if @artwork_request.artwork_ids.empty?
      end

      @order = Order.find(@artwork_request.jobs.first.order.id)
    end

    super do |success, _failure|
      if @artwork.nil?
        success.js { notify_artist }
      end
    end
  end

  def create
    super do |success, _failure|
      success.js { notify_artist }
    end
  end

  private

  def notify_artist
    ArtistMailer.artist_notification(@artwork_request, action_name).deliver
  end

  # TODO: Nick, David, extract and refactor format_time
  def format_time
    if params[:artwork_id].nil?
      begin
        time = DateTime.strptime(params[:artwork_request][:deadline], '%m/%d/%Y %H:%M %p').to_time unless (params[:artwork_request].nil? or params[:artwork_request][:deadline].nil?)
        offset = (time.utc_offset)/60/60
        adjusted_time = (time - offset.hours).utc
        params[:artwork_request][:deadline] = adjusted_time
      rescue ArgumentError
        params[:artwork_request][:deadline]
      end
    end
  end

  def assign_order
    @order = Order.find(params[:order_id]) unless params[:order_id].nil?
  end

  def permitted_params
    params.permit(:order_id, :id,
                  artwork_request:[
                    :id, :priority, :description, :artist_id,
                    :imprint_method_id, :print_location_id, :salesperson_id,
                    :deadline, :artwork_status, job_ids: [], ink_color_ids: [],
                    artwork_ids: [],
                    assets_attributes: [
                      :file, :description, :id, :_destroy
                    ]
                  ])
  end
end
