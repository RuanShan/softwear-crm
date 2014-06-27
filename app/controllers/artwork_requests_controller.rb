class ArtworkRequestsController < InheritedResources::Base
  before_filter :format_time, only: [:create, :update]
  before_filter :assign_order

  def new
    super do |format|
      format.js
    end
  end

  def edit
    super do |format|
      format.js
    end
  end

  def create
    @artwork_request = ArtworkRequest.create!(permitted_params[:artwork_request])
    super do |success, failure|
      success.js
      failure.js {render partial: 'shared/modal_errors', locals: { object: @artwork_request } }
    end
  end

  def destroy
    @artwork_request = ArtworkRequest.find(params[:id])
    respond_to do |format|
      format.js
    end
    @artwork_request.destroy
  end

  def update
    @artwork_request = ArtworkRequest.find(params[:id])
    @artwork_request.update_attributes(permitted_params[:artwork_request])
    respond_to do |format|
      format.js
    end
  end

  private

  def format_time
    params[:artwork_request][:deadline] = DateTime.strptime(params[:artwork_request][:deadline], '%m/%d/%Y %H:%M %p') unless (params[:artwork_request].nil? or params[:artwork_request][:deadline].nil?)
  end

  def assign_order
    @order = Order.find(params[:order_id])
  end

  def permitted_params
    params.permit(:order_id,
                  artwork_request: [:id, :description, :artist_id,
                                    :imprint_method_id, :print_location_id,
                                    :salesperson_id, :deadline, :artwork_status, :assets, job_ids: [], ink_color_ids: []])

  end
end
