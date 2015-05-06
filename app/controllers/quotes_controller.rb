class QuotesController < InheritedResources::Base
  before_filter :format_dates, only: [:create, :update]
  after_filter :dock_associated_quote_requests, only: [:show, :edit]
  before_action :set_current_action
  require 'mail'

  def new
    assign_new_quote_hash
    add_params_from_docked_quote_request
    super do
      @quote_request_id = params[:quote_request_id] if params.has_key?(:quote_request_id)
      # TODO: this is pretty gross...
      unless @new_quote_hash[:price_information].nil?
        @new_quote_hash[:price_information].each do |_key, outer_value|
          unless outer_value.nil?
            outer_value.each do |inner_value|
              new_line_item = LineItem.new(name: inner_value[:name],
                                           unit_price: inner_value[:prices][:base_price],
                                           url: inner_value[:supplier_link],
                                           quantity: inner_value[:quantity])
              @quote.line_items << new_line_item
            end
          end
        end
      end
      @quote.line_item_groups.build.line_items.build
      @current_action = 'quotes#new'
    end
  end

  def index
    @current_action = 'quotes#index'

    if params[:q]
      @quotes = Quote.search do
        fulltext params[:q]
      end
        .results
    else
      @quotes = Quote.all.page(params[:page])
    end

    respond_to do |format|
      format.json do
        render json: @quotes.to_json
      end
      format.html
    end
  end

  def edit
    super do
      @current_user = current_user
      @current_action = 'quotes#edit'
      @activities = @quote.all_activities
    end
  end

  def show
    super do |format|
      format.json do
        render json: {
          result: 'success',
          content: render_string(partial: 'line_items/standard_view',
                                 locals: { line_items: @quote.standard_line_items })
        }
      end
      format.html
    end
  end

  def create
    assign_new_quote_hash
    session[:last_quote_line_items] = params[:quote].try(:[], :line_items_attributes)

    super do
      # create QuoteRequestQuote if necessary
      unless @quote_request_id.nil?
        unless QuoteRequestQuote.new(quote_request_id: @quote_request_id,
                                     quote_id: @quote.id).save
          flash[:error] = 'Something went wrong creating your quote from a request!'
        end
      end

      if params[:line_item_group_name] && @quote.valid?
        @quote
          .default_group
          .update_attributes(name: params[:line_item_group_name])

      end
      @quote
      # scrapping for now since freshdesk is a piece of shit
      # @quote.create_freshdesk_ticket(current_user) if Rails.env.production?
    end

    session.delete(:last_quote_line_items)
  end

  def quote_select
    respond_to do |format|
      @quote_select_hash = {}
      @quote_select_hash[:quotes] = Quote.all
      index = @quote_select_hash[:index] = params[:index].to_i
      pricing_group = @quote_select_hash[:pricing_group] = params[:pricing_group]

      name = session[:pricing_groups][pricing_group.to_sym][index][:name]
      unit_price = session[:pricing_groups][pricing_group.to_sym][index][:prices][:base_price]
      description = session[:pricing_groups][pricing_group.to_sym][index][:description]

      @quote_select_hash[:new_line_item] = LineItem.new(name: name, unit_price: unit_price, description: description)

      format.js
    end
  end

  def stage_quote
    @quote = Quote.find(params[:quote_id])

    group = @quote.line_item_groups.first
    saved = group.line_items.new(name: params[:name],
                         unit_price: params[:total_price],
                         description: params[:description],
                         quantity: 1).save

    if saved
      fire_activity(@quote, :added_line_item)
    else
      flash[:error] = 'The line item could not be added to the quote.'
    end

    redirect_to edit_quote_path params[:quote_id]
  end

  private

  def dock_associated_quote_requests
    if @quote
      session[:docked] = @quote.quote_requests.map(&:to_dock)
    end
  end

  def add_params_from_docked_quote_request
    docked = session[:docked]
    return if docked.nil?

    params[:name]             = docked.name
    params[:email]            = docked.email
    params[:quote_request_id] = docked.id
  end

  def assign_new_quote_hash
    @new_quote_hash = {}

    @new_quote_hash[:price_information] = session[:pricing_groups]
    @new_quote_hash[:line_item_group_name] = params[:line_item_group_name] if params[:line_item_group_name]

    if defined? params[:quote][:line_items_attributes]
      @new_quote_hash[:quote_li_attributes] = params[:quote][:line_items_attributes]
    end
  end

  def set_current_action
    @current_action = 'quotes'
  end

  def format_dates
    unless params[:quote].nil? or params[:quote][:valid_until_date].nil?
      valid_until_date = params[:quote][:valid_until_date]
      params[:quote][:valid_until_date] = format_time(valid_until_date)
    end

    unless params[:quote].nil? or params[:quote][:estimated_delivery_date].nil?
      estimated_delivery_date = params[:quote][:estimated_delivery_date]
      params[:quote][:estimated_delivery_date] = format_time(estimated_delivery_date)
    end
  end

  def permitted_params
    params.permit(
      :line_item_group_name,
      quote: [
      :email, :informal, :phone_number, :first_name, :last_name, :company,
      :twitter, :name, :valid_until_date, :estimated_delivery_date,
      :salesperson_id, :store_id, :shipping, :quote_source, :freshdesk_ticket_id,
      :is_rushed, :qty, :deadline_is_specified,
       quote_request_ids: [],
       line_items_attributes: [
        :name, :quantity, :taxable, :description, :id,
        :imprintable_variant_id, :unit_price, :_destroy, :url,
        :group_name
       ],
       emails_attributes: [
           :subject, :body, :sent_to, :sent_from, :cc_emails, :id, :_destroy
       ]] + Quote::INSIGHTLY_FIELDS)
  end
end
