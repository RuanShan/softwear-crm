class QuotesController < InheritedResources::Base
  before_filter :format_dates, only: [:create, :update]
  before_action :set_current_action
  require 'mail'

  def new
    add_params_from_docked_quote_request
    super do
      @quote_request_id = params[:quote_request_id] if params.has_key?(:quote_request_id)
      # TODO: this is pretty gross...
      @current_action = 'quotes#new'
    end
  end

  def index
    super do
      @current_action = 'quotes#index'
      @quotes = Quote.all.page(params[:page])
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


  private

  def add_params_from_docked_quote_request
    # Todo @quote.assign_from_qoute_request(whatver from session)
    docked = session[:docked]
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
        line_items_from_group_attributes: [
          :imprintable_group_id, :quantity, :decoration_price
        ],
        emails_attributes: [
            :subject, :body, :sent_to, :sent_from, :cc_emails, :id, :_destroy
      ]] + Quote::INSIGHTLY_FIELDS)
  end
end
