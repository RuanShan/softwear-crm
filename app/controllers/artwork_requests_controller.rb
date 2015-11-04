class ArtworkRequestsController < InheritedResources::Base
  before_filter :assign_order
  before_filter :format_deadline, only: [:create, :update]
  before_filter :set_current_action
  before_filter :assign_artwork_request_states

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

  # TODO couldn't figure out a way to refactor this, but could possibly be too much for a controller?
  def update
    unless params[:artwork_id].nil?
      @artwork_request = ArtworkRequest.find(params[:id])
      @artwork = Artwork.find(params[:artwork_id])

      if params[:remove_artwork].nil?
        @artwork_request.artworks << @artwork
        @artwork_request.state = 'Art Created'
      else
        @artwork_request.artworks.delete(@artwork)
        @artwork_request.state = 'Pending' if @artwork_request.artwork_ids.empty?
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

  def manager_dashboard
    @unassigned = ArtworkRequest.search do 
      with :state, :unassigned
    end.results

    @pending_artwork = ArtworkRequest.search do 
      with :state, :pending_artwork
    end.results

    @pending_manager_approval = ArtworkRequest.search do 
      with :state, :pending_manager_approval
    end.results

    @ready_to_proof = []
    @proofs_awaiting_approval = []
    @pending_production = []
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
                    :exact_or_approximate, :deadline, :state, 
                    ink_color_ids: [],
                    artwork_ids: [],
                    imprint_ids: [],
                    assets_attributes: [
                      :file, :description, :id, :_destroy
                    ]
                  ])
  end

  def assign_artwork_request_states
    @artwork_request_states = ArtworkRequest.state_machine.states.map{|x| [x.human_name.humanize, x.name] }
  end

end
