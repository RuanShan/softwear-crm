class OrdersController < InheritedResources::Base
  before_filter :format_in_hand_by, only: [:create, :update]

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
      super do
        if session.has_key? :quote_id
          unless OrderQuote.new(quote_id: session[:quote_id], order_id: @order.id).save
            flash[:error] = 'Something went wrong creating your order!'
          end
          session[:quote_id] = nil
        end
      end
      return
    end

    @order = Order.create(permitted_params[:order])
    if session.has_key? :quote_id
      unless OrderQuote.new(quote_id: session[:quote_id], order_id: @order.id).save
        flash[:error] = 'Something went wrong creating your order!'
      end
      session[:quote_id] = nil
    end

    if @order.valid?
      @order.generate_jobs(params[:job_attributes].map(&JSON.method(:parse))) if params[:job_attributes]
      redirect_to order_path @order
    else
      @empty = Store.all.empty?
      render 'new_fba'
    end
  end

  def production_dashboard
    @order = Order.find(params[:id])
    @production_order = @order.production_order
    respond_to do |format|
      format.html
      format.js
    end
  end

  def names_numbers
    @order = Order.find(params[:id])
    filename = "order_#{@order.name}_names_numbers.csv"

    send_data @order.name_number_csv, filename: sanitize_filename(filename)
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
    params.permit('script_container_id')
    params.permit('options').permit!
    options = params['options']
    options = JSON.parse(options) if options.is_a?(String)

    packing_slips = params[:packing_slips]

    return if packing_slips.nil?

    @file_name = packing_slips.first.original_filename
    @script_container_id = params[:script_container_id]

    @fba_infos = packing_slips.map do |packing_slip|
      FBA.parse_packing_slip(StringIO.new(packing_slip.read), options)
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

  def state
    @order = Order.find(params[:id])
    @transition = params[:transition].to_sym unless params[:transition].nil?
    @machine = params[:state_machine]
    transition_order if (@machine && @transition)
    respond_to do |format|
      format.js
    end
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

  def transition_order
    if @order.send("#{@machine}_events").include? @transition
      old_state = @order.send(@machine)
      PublicActivity.enabled = false
      @order.send("fire_#{@machine}_event",  @transition)
      PublicActivity.enabled = true
      transition_params = {
        old_state: old_state,
        new_state: @order.send(@machine),
        machine: params[:state_machine],
        transition: params[:transition],
        details: params[:details]
      }
      @order.create_activity(
            action:     :transition,
            parameters: transition_params,
            owner:      current_user
      )
      @order.reload
      @successful_transition = true if @order.valid?
    else
      @order.errors.add(:base, "Invalid transition '#{@transition.to_s.humanize}' for
                        '#{@machine.to_s.humanize}' from state '#{@order.send(@machine).humanize}'")
    end
  end

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
      :job_attributes,

      order: [
        :email, :firstname, :lastname,
        :company, :twitter, :name, :po,
        :in_hand_by, :terms, :tax_exempt,
        :tax_id_number, :redo_reason, :invoice_state,
        :delivery_method, :phone_number, :commission_amount,
        :store_id, :salesperson_id, :total, :shipping_price,
        :freshdesk_proof_ticket_id,
        quote_ids: []
      ]
    )
  end
end
