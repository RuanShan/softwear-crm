class ArtworkRequestsController < InheritedResources::Base
  before_filter :assign_order
  before_filter :format_deadline, only: [:create, :update]
  before_filter :set_current_action

  respond_to :js

  def create
    super do |success, _failure|
      success.js { notify_artist }
      success.html do
        notify_artist
        redirect_to order_path(@order, anchor: 'artwork')
      end
    end
  end

  # TODO couldn't figure out a way to refactor this, but could possibly be too much for a controller?
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
        success.html do
          notify_artist
          redirect_to order_path(@order, anchor: 'artwork')
        end
      end
    end
  end

  def manager_dashboard
    @unassigned_artwork_requests = ArtworkRequest.unassigned
    @pending_artwork_requests = ArtworkRequest.pending
    @pending_proof_requests = Proof.pending
  end

  protected

  def set_current_action
    @current_action = 'artwork_requests'
  end

  private

  def assign_order
    @order = Order.find(params[:order_id]) unless params[:order_id].nil?
  end

  def notify_artist
    ArtistMailer.artist_notification(@artwork_request, action_name).deliver
  end

  def format_deadline
    if params[:artwork_id].nil?
      unless params[:artwork_request].nil? || params[:artwork_request][:deadline].nil?
        deadline = params[:artwork_request][:deadline]
        params[:artwork_request][:deadline] = format_time(deadline)
      end
    end
  end

  def permitted_params
    params.permit(:order_id, :id,
                  artwork_request:[
                    :id, :priority, :description, :artist_id,
                    :imprint_method_id, :salesperson_id,
                    :deadline, :artwork_status, ink_color_ids: [],
                    artwork_ids: [],
                    imprint_ids: [],
                    assets_attributes: [
                      :file, :description, :id, :_destroy
                    ]
                  ])
  end
end
