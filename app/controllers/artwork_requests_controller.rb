class ArtworkRequestsController < InheritedResources::Base
  before_filter :format_time, only: [:create, :update]
  before_filter :assign_order
  respond_to :js

  private

  def format_time
    begin
      params[:artwork_request][:deadline] = DateTime.strptime(params[:artwork_request][:deadline], '%m/%d/%Y %H:%M %p') unless (params[:artwork_request].nil? or params[:artwork_request][:deadline].nil?)
    rescue ArgumentError
      params[:artwork_request][:deadline]
    end
  end

  def assign_order
    @order = Order.find(params[:order_id]) unless params[:order_id].nil?
  end

  def permitted_params
    params.permit(:order_id,
                  artwork_request: [:id, :description, :artist_id,
                                    :imprint_method_id, :print_location_id,
                                    :salesperson_id, :deadline, :artwork_status, assets_attributes: [:file, :description, :id, :_destroy], job_ids: [], ink_color_ids: []])

  end
end
