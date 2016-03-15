class OrdersController < InheritedResources::Base
  include StateMachine

  skip_before_action :verify_authenticity_token, only: [:fba_job_info]
  before_filter :format_in_hand_by, only: [:create, :update]
  layout 'no_overlay', only: [:show]

  def index
    super do
      @current_action = 'orders#index'
      @orders = Order.all.page(params[:page])
    end
  end

  def update
    super do |success, failure|
      success.html do
        if @order.fba?
          redirect_to edit_order_path(params[:id], anchor: 'jobs')
        else
          redirect_to edit_order_path(params[:id], anchor: 'details')
        end
      end
      failure.html do
        assign_activities
        render action: :edit, anchor: 'details'
      end
    end
  end

  def new
    super do
      @current_action = 'orders#new'
      @current_user = current_user
      @empty = Store.all.empty?

      if params.has_key? :quote_id
        quote = Quote.find(params[:quote_id])

        session[:quote_id] = params[:quote_id]
        @order = Order.new(
          email: quote.email,
          phone_number: quote.phone_number,
          firstname: quote.first_name,
          lastname: quote.last_name,
          company: quote.company,
          twitter: quote.twitter,
          name: quote.name,
          store_id: quote.store_id
        )
      end
    end
  end

  def edit
    super do
      @current_action = 'orders#edit'
      @shipping_methods = grab_shipping_methods
      assign_activities
    end
  end

  def create
    @order = Order.new(permitted_params[:order])
    valid = false
    # nested attributes assignment does not work with the polymorphic jobs
    if params[:order][:jobs_attributes]
      if @order.save
        @order.jobs_attributes = params.permit![:order][:jobs_attributes]
        if @order.save
          @order.setup_art_for_fba if @order.fba?
          valid = true
        else
          @order.really_destroy!
        end
      end
    else
      valid = @order.save
    end

    if valid
      if session.has_key? :quote_id
        unless OrderQuote.new(quote_id: session[:quote_id], order_id: @order.id).save
          flash[:error] = "Couldn't attach quote to order"
        end
        session[:quote_id] = nil
      end
      flash[:success] = "Order was successfully created."
      redirect_to edit_order_path(@order)
    else
      flash[:error] = @order.errors.full_messages.join("\n") if @order.fba?
      render action: @order.fba? ? :new_fba : :new
    end
  end

  def destroy
    @order = Order.find(params[:id])
    @order.destroy_recursively
    respond_to do |format|
      format.html { redirect_to orders_path }
      format.js { render }
    end
  end

  def production_dashboard
    @order = Order.find(params[:id])
    @production_order = @order.production if @order.production?

    respond_to do |format|
      format.html
      format.js
    end
  end

  def fba
    @current_action = 'orders#fba'
    @orders = Order.fba.page(params[:page])
    @fba = true

    render action: :index
  end

  def new_fba
    new! do
      @current_action = 'orders#new_fba'
      @empty = Store.all.empty?
    end
  end

  def fba_job_info
    packing_slips = params[:packing_slips]
    packing_slip_urls = params[:packing_slip_urls]

    @fba_infos = []

    if packing_slips
      if packing_slips.is_a?(Hash)
        packing_slips = packing_slips.values
      end

      @fba_infos += packing_slips.compact.flat_map do |packing_slip|
        FBA.parse_packing_slip(
          StringIO.new(packing_slip.read),
          filename:   packing_slip.original_filename,
          shipped_by_id: current_user.id
        )
      end
    end

    if packing_slip_urls
      @fba_infos += packing_slip_urls.split("\n").compact.flat_map do |url|
        next if url =~ /^\s*$/
        url.strip!

        FBA.parse_packing_slip(
          StringIO.new(URI.parse(url).read),
          filename:   url.split('/').last,
          shipped_by_id: current_user.id
        )
      end
    end

    @fba_infos.compact!

    respond_to do |format|
      format.js
      format.json do
        result = @fba_infos.map do |fba|
          {
            container: render_string(partial: 'fba_upload', locals: { filename: fba[:filename] }),
            info:      render_string(partial: 'fba_job_info_box', locals: { fba: fba })
          }
        end
        render json: result.to_json
      end
    end
  end

  def imprintable_order_sheets
    @order = Order.find(params[:id])
    render layout: 'no_overlay'
  end

  def order_report
    @order = Order.find(params[:id])
    render layout: 'no_overlay'
  end


  def send_to_production
    @order = Order.find(params[:id])
    if @order.production?
      flash[:error] = "This order already has a Production entry: #{@order.production_url}"
      redirect_to edit_order_path(@order) and return
    end
    @order.enqueue_create_production_order force: false

    flash[:success] =
      "This order should appear in SoftWEAR Production within the next few minutes."

    redirect_to edit_order_path(@order)
  end

  private

  def format_in_hand_by
    unless params[:order].nil? || params[:order][:in_hand_by].nil?
      in_hand_by = params[:order][:in_hand_by]
      params[:order][:in_hand_by] = format_time(in_hand_by)
    end
  end

  def assign_activities
    @activities = @order.all_activities
  end

  def grab_shipping_methods
    if @order.fba?
      ShippingMethod.all
    else
      fba_filter = '"%Amazon FBA%"'
      ShippingMethod.where.not("name LIKE #{fba_filter}") +
      [ShippingMethod.find_by("name LIKE #{fba_filter}")].compact
    end
  end

  def permitted_params
    params.permit(
      :packing_slips, :page,
      :fba_jobs,

      order: [
        :id, :imported_from_admin,
        :email, :firstname, :lastname,
        :company, :twitter, :name, :po,
        :in_hand_by, :terms, :tax_exempt,
        :tax_id_number, :redo_reason, :invoice_state,
        :delivery_method, :phone_number, :commission_amount,
        :store_id, :salesperson_id, :total, :shipping_price, :artwork_state,
        :freshdesk_proof_ticket_id, :softwear_prod_id, :production_state, :phone_number_extension,
        :freshdesk_proof_ticket_id, :softwear_prod_id, :production_state,

        quote_ids: [],
        jobs_attributes: [
          :id, :name, :jobbable_id, :jobbable_type, :description, :_destroy,
          :shipping_location, :shipping_location_size, :sort_order, :fba_job_template_id,
          imprints_attributes: [
            :print_location_id, :description, :_destroy, :id
          ],
          line_items_attributes: [
            :imprintable_object_id, :imprintable_object_type, :id,
            :line_itemable_id, :line_itemable_type, :quantity,
            :unit_price, :decoration_price, :_destroy, :imprintable_price
          ],
          shipments_attributes: [
            :name, :address_1, :city, :state, :zipcode, :shipped_by_id,
            :shippable_type, :shippable_id, :id, :_destroy, :time_in_transit,
            :shipping_method_id
          ]
        ]
      ]
    )
  end
end
