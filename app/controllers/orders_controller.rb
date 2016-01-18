class OrdersController < InheritedResources::Base
  include StateMachine

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
        redirect_to edit_order_path(params[:id], anchor: 'details')
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
      assign_activities
    end
  end

  def create
    unless params[:order].try(:[], 'terms') == 'Fulfilled by Amazon'
      super do |success, failure|
        if session.has_key? :quote_id
          unless OrderQuote.new(quote_id: session[:quote_id], order_id: @order.id).save
            flash[:error] = "Couldn't attach quote to order"
          end
          session[:quote_id] = nil
        end
        success.html { redirect_to edit_order_path(@order) }
        failure.html { render action: :new }
      end
      return
    end

    @order = Order.create(permitted_params[:order])

    if @order.valid?
      @order.generate_jobs(params[:fba_jobs].map(&JSON.method(:parse))) if params[:fba_jobs]
      redirect_to edit_order_path @order
    else
      @empty = Store.all.empty?
      render 'new_fba'
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
    byebug
    packing_slips = params[:packing_slips]
    packing_slip_urls = params[:packing_slip_urls]

    @fba_infos = []

    if packing_slips
      @fba_infos += packing_slips.compact.map do |packing_slip|
        FBA.parse_packing_slip(
          StringIO.new(packing_slip.read),
          filename: packing_slip.original_filename
        )
      end
    end

    if packing_slip_urls
      @fba_infos += packing_slip_urls.split("\n").compact.map do |url|
        next if url =~ /^\s*$/
        url.strip!

        FBA.parse_packing_slip(
          StringIO.new(URI.parse(url).read),
          filename: url.split('/').last
        )
      end
    end

    @fba_infos.try(:compact!)
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

  def permitted_params
    params.permit(
      :packing_slips, :page,
      :fba_jobs,

      order: [
        :id,
        :email, :firstname, :lastname,
        :company, :twitter, :name, :po,
        :in_hand_by, :terms, :tax_exempt,
        :tax_id_number, :redo_reason, :invoice_state,
        :delivery_method, :phone_number, :commission_amount,
        :store_id, :salesperson_id, :total, :shipping_price, :artwork_state,
        :freshdesk_proof_ticket_id, :softwear_prod_id, :production_state,
        quote_ids: []
      ]
    )
  end
end
