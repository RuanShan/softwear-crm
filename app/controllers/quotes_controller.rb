class QuotesController < InheritedResources::Base
  before_filter :format_times, only: [:create, :update]
  require 'mail'

  def new
    super do
      @quote.line_items.build
      @current_user = current_user
    end
  end

  def edit
    super do |format|
      @current_user = current_user
      @activities = @quote.all_activities
      format.html
    end
  end

  def show
    super do |format|
      format.json do
        render json: {
            result: 'success',
            content: render_string(partial: 'line_items/standard_view', locals: { line_items: @quote.standard_line_items })
        }
      end
      format.html { render 'quotes/show', layout: 'no_overlay' }
    end
  end

  def create
    super do
      # only want to create freshdesk tickets if we're not running the spec and we're not the admin (for development)
      @quote.create_freshdesk_ticket(current_user) unless (current_user.full_name.downcase.include?('test') || current_user.full_name.downcase.include?('admin'))
    end
  end

  def quote_select
    respond_to do |format|
      @quotes = Quote.all
      @index = params[:index].to_i
      name = session[:prices][@index][:name]
      unit_price = session[:prices][@index][:prices][:base_price]
      @new_line_item = LineItem.new(name: name, unit_price: unit_price, description: 'Canned Description')
      format.js
    end
  end

  def stage_quote
    @quote = Quote.find(params[:quote_id])
    @quote.line_items.new(name: params[:name],
                         unit_price: params[:total_price],
                         description: 'Canned Description',
                         quantity: 0).save
    @quote.create_activity :added_line_item, owner: current_user
    redirect_to edit_quote_path params[:quote_id]
  end

  def email_customer
    @quote = Quote.find(params[:quote_id])
    
    hash = {
      quote: @quote,
      body: params[:email_body],
      subject: params[:email_subject],
      from: current_user.email,
      to: @quote.email
    }

    begin
      QuoteMailer.email_customer(hash).deliver
      flash[:success] = 'Your email was successfully sent!'
      @quote.create_activity :emailed_customer, owner: current_user
    rescue Net::SMTPAuthenticationError, Net::SMTPServerBusy, Net::SMTPSyntaxError, Net::SMTPFatalError, Net::SMTPUnknownError => e
      flash[:notice] = 'Your email was unable to be sent'
      flash[:success] = nil
      @activity = PublicActivity::Activity.find_by_trackable_id(params[:quote_id])
      @activity.destroy
    end

    redirect_to edit_quote_path params[:quote_id]
  end

  def populate_email_modal
    respond_to do |format|
      @quote = Quote.find(params[:quote_id])
      format.js
    end
  end

  private

  def format_times
    format_time(:valid_until_date)
    format_time(:estimated_delivery_date)
  end

  def format_time(attribute)
    begin
      time = DateTime.strptime(params[:quote][attribute], '%m/%d/%Y %H:%M %p').to_time unless (params[:quote].nil? or params[:quote][attribute].nil?)
      offset = (time.utc_offset)/60/60
      adjusted_time = (time - offset.hours).utc
      params[:quote][attribute] = adjusted_time
    rescue ArgumentError
      params[:quote][attribute]
    end
  end

  def permitted_params
    params.permit(quote:
                      [:email, :phone_number, :first_name, :last_name, :company,
                       :twitter, :name, :valid_until_date, :estimated_delivery_date,
                       :salesperson_id, :store_id,
                       line_items_attributes:
                         [:name, :quantity, :taxable, :description, :id,
                         :imprintable_variant_id, :unit_price, :_destroy]
                      ])
  end
end
