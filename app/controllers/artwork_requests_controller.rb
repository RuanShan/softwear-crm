class ArtworkRequestsController < InheritedResources::Base
  include StateMachine

  TAB_CONTENT = {
    unassigned: lambda do
      ArtworkRequest.search do
        with :state, :unassigned
      end.results
        .reject(&:deleted_at)
    end,

    pending_artwork: lambda do
      ArtworkRequest.search do
        with :state, [:pending_artwork, :artwork_rejected]
      end.results
        .reject(&:deleted_at)
    end,

    pending_manager_approval: lambda do
      ArtworkRequest.search do
        with :state, :pending_manager_approval
      end.results
        .reject(&:deleted_at)
    end,

    ready_to_proof: lambda do
      Order.search do
        with :artwork_state, [:pending_proofs, :pending_manager_approval, :pending_proof_submission]
      end.results
    end,

    proofs_awaiting_approval: lambda do
      Order.search do
        with :artwork_state, :pending_customer_approval
      end.results
    end,

    pending_production: lambda do
      Order.search do
        with :artwork_state, :ready_for_production
      end.results
    end
  }

  before_filter :assign_order 
  before_filter :format_deadline, only: [:create, :update]
  before_filter :set_current_action

  respond_to :js

  def create
    super do |success, _failure|
      success.js
      success.html do
        redirect_to edit_order_path(@order, anchor: 'artwork')
      end
    end
  end

  def index
    @current_action = 'artwork_requests#index'
    @artwork_requests = ArtworkRequest.all.page(params[:page] || 1)
  end

  def update
    unless params[:artwork_id].nil?
      @artwork_request = ArtworkRequest.find(params[:id])
      @artwork = Artwork.find(params[:artwork_id])

      if params[:remove_artwork].nil?
        @artwork_request.artworks << @artwork
      else
        @artwork_request.artworks.delete(@artwork)
        @artwork_request.artwork_removed
      end

      @order = Order.find(@artwork_request.jobs.first.order.id)
    end

    super do |success, _failure|
      if @artwork.nil?
        success.js { notify_artist }
        success.html do
          notify_artist
          redirect_to edit_order_path(@order, anchor: 'artwork')
        end
      else
        success.html { redirect_to edit_order_path(@order, anchor: 'artwork') }
      end
    end
  end

  def show
    super do |format|
      format.html do
        order = Order.joins(:artwork_requests).where(artwork_requests: { id: params[:id] }).first
        raise "Couldn't find order including artwork request of ID #{params[:id]}" if order.nil?
        redirect_to edit_order_path(order, anchor: 'artwork')
      end
      format.js
      format.json
    end
  end

  def manager_dashboard
    @unassigned = TAB_CONTENT[:unassigned].call
  end

  def tab
    @tab = params[:tab]
    @tab_content = TAB_CONTENT[@tab.to_sym].call

    respond_to do |format|
      format.js
    end
  end

  def approve_all
    @order = Order.find(params[:id]) 
    @artwork_requests = @order.artwork_requests
   
    @artwork_requests.each do |req|
      if req.can_approved? 
        req.approved_by = current_user
        req.approved!
        req.index
      end
    end
    
    respond_to do |format|
      format.html { redirect_to edit_order_path(@order, anchor: 'artwork') }
    end
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
    return if @artwork_request.artist.blank?
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
                    :imprint_method_id, :salesperson_id, :reorder,
                    :exact_recreation, :deadline, :state,
                    :amount_paid_for_artwork,
                    ink_color_ids: [],
                    artwork_ids: [],
                    imprint_ids: [],
                    assets_attributes: [
                      :file, :description, :id, :_destroy
                    ]
                  ])
  end

end
