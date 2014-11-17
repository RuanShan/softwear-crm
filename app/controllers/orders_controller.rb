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

  def show
    redirect_to action: :edit
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
      @order.generate_jobs(params[:job_attributes].map(&JSON.method(:parse)))
      redirect_to order_path @order
    else
      @empty = Store.all.empty?
      render 'new_fba'
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
      :job_attributes,

      order: [
        :email, :firstname, :lastname,
        :company, :twitter, :name, :po,
        :in_hand_by, :terms, :tax_exempt,
        :tax_id_number, :redo_reason,
        :delivery_method, :phone_number, :commission_amount,
        :store_id, :salesperson_id, :total,

        quote_ids: []
      ]
    )
  end
end
