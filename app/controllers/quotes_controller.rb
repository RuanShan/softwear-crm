class QuotesController < InheritedResources::Base
  before_filter :format_dates, only: [:create, :update]
  after_filter :dock_associated_quote_requests, only: [:show, :edit]
  before_action :set_current_action
  require 'mail'

  def new
    super do
      @quote_request_id = params[:quote_request_id]         if params.has_key?(:quote_request_id)
      @quote_request = QuoteRequest.find(@quote_request_id) if @quote_request_id
      @quote.assign_from_quote_request(@quote_request)      if @quote_request
      # TODO: this is pretty gross...
      @current_action = 'quotes#new'
    end
  end

  def index
    @current_action = 'quotes#index'

    if (terms = params[:q])
      @quotes = Quote.search do
        fulltext terms
      end
        .results

      if params[:respond_with_partial]
        respond_to do |format|
          format.js do
            render partial: params[:respond_with_partial],
                   locals: { quotes: @quotes }
          end
        end
      else
        respond_to do |format|
          format.json do
            render json: @quotes.to_json
          end
          format.html
        end
      end
    else
      super do
        @quotes = Quote.all.page(params[:page])
      end
    end
  end

  def edit

    super do |format|
      format.html do
        @current_user = current_user
        @current_action = 'quotes#edit'
        @activities = @quote.all_activities
      end
      format.js
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

  def update
    super do |format|
      format.js
      format.html { redirect_to action: :edit }
    end
  end

  def integrate
    @quote = Quote.find(params[:id])
    @integrate_with = params[:with]

    @result =
      case @integrate_with
      when 'insightly'
        if @quote.insightly_opportunity_id.nil?
          @quote.create_insightly_opportunity
        else
          StandardError.new("quote already has an Opportunity!")
        end
      when 'freshdesk'
        if @quote.freshdesk_ticket_id.nil?
          @quote.create_freshdesk_ticket
        else
          StandardError.new("quote already has a Freshdesk Ticket!")
        end
      else StandardError.new("Unknown integration: #{params[:with] || '(none)'}")
      end

    respond_to(&:js)
  end

  private

  def dock_associated_quote_requests
    if @quote
      session[:docked] = @quote.quote_requests.map(&:to_dock)
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
      :imprintables,
      quote: [
        :imprintables,
        :email, :informal, :phone_number, :first_name, :last_name, :company,
        :twitter, :name, :valid_until_date, :estimated_delivery_date,
        :salesperson_id, :store_id, :shipping, :quote_source, :freshdesk_ticket_id,
        :is_rushed, :qty, :deadline_is_specified, :insightly_whos_responsible_id,
        quote_request_ids: [],
        line_items_attributes: [
          :name, :quantity, :taxable, :description, :id,
          :imprintable_variant_id, :unit_price, :_destroy, :url,
          :group_name
        ],
        line_items_from_group_attributes: [
          :imprintable_group_id, :quantity, :decoration_price,
          print_locations: [], imprint_descriptions: []
        ],
        line_item_to_group_attributes: [
          :job_id, :tier, :quantity,
          :decoration_price, :persisted,
          imprintables: []
        ],
        emails_attributes: [
            :subject, :body, :sent_to, :sent_from, :cc_emails, :id, :_destroy
      ]] + Quote::INSIGHTLY_FIELDS)
  end
end
