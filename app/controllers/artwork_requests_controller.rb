class ArtworkRequestsController < InheritedResources::Base
  def new
    super do |format|
      format.html { render partial: 'orders/artwork_new', locals: { artwork_request: ArtworkRequest.new, order: Order.find(params[:order_id]) }  }
    end
  end

  def edit
    super do |format|
      format.html { render partial: 'orders/artwork_edit', locals: { artwork_request: @artwork_request } }
    end
  end

  def show
    super do |format|
      format.html { render partial: 'orders/artwork_view', locals: { artwork_request: @artwork_request } }
    end
  end

  def create
    super do |success, failure|
      success.json do
        render json: { result: 'success',  }
      end
      failure.json do
        modal_html = 'ERROR'
        with_format :html do
        modal_html = render_to_string(partial: 'shared/modal_errors', locals: { object: @artwork_request })
        end
        render json: {
            result: 'failure',
            errors: @artwork_request.errors.messages,
            modal: modal_html
        }
      end
    end
  end

  def destroy
    if params[:ids]
      LineItem.destroy params[:ids].split('/').flatten.map { |e| e.to_i }
      render json: { result: 'success' }
    else
      super do |success, failure|
        success.json do
          render json: { result: 'success' }
        end
        failure.json do
          render json: { result: 'failure' }
        end
      end
    end
  end

  def update
    super do |success, failure|
      success.html { redirect_to artwork_request_path }
      failure.html { render action: :edit }
    end
  end

  private

  def permitted_params
    params.permit(:order_id, artwork_request: [:description, :artist_id, :imprint_method_id, :print_location_id, :salesperson_id, :deadline, :artwork_status,
                                               users_attributes: [:email, :firstname, :lastname, :store_id],
                                               imprint_methods_attributes: [:name, :production_name],
                                               print_locations_attributes: [:name, :max_height, :max_width],
                                               ink_colors_attributes: [:name, :imprint_method_id, :id, :_destroy],
                                               job: [:id, :name, :description]])
  end
end
