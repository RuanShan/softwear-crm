class ArtworkRequestsController < InheritedResources::Base
  before_filter :format_time, only: [:create, :update]
  before_filter :assign_order
  after_filter :notify_artists, only: [:create, :update]

  respond_to :js

  private

  def notify_artists
    action = action_name + 'd'
    ArtistMailer.notify_artist(@artwork_request.salesperson, @artwork_request, @artwork_request.artist, action).deliver
  end

  def format_time
    begin
      time = DateTime.strptime(params[:artwork_request][:deadline], '%m/%d/%Y %H:%M %p').to_time unless (params[:artwork_request].nil? or params[:artwork_request][:deadline].nil?)
      offset = (time.utc_offset)/60/60
      adjusted_time = (time - offset.hours).utc
      params[:artwork_request][:deadline] = adjusted_time
    rescue ArgumentError
      params[:artwork_request][:deadline]
    end
  end

  def assign_order
    @order = Order.find(params[:order_id]) unless params[:order_id].nil?
  end

  def permitted_params
    params.permit(:order_id,
                  artwork_request: [:id, :priority, :description, :artist_id,
                                    :imprint_method_id, :print_location_id,
                                    :salesperson_id, :deadline, :artwork_status, assets_attributes: [:file, :description, :id, :_destroy], job_ids: [], ink_color_ids: []])

  end
end
