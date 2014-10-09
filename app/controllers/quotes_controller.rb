class QuotesController < InheritedResources::Base
  before_filter :format_dates, only: [:create, :update]
  before_action :set_current_action
  require 'mail'

  def new
    assign_new_quote_hash
    super do
      @quote.line_item_groups.build.line_items.build
      @current_action = 'quotes#new'
    end
  end

  def index
    super do
      @current_action = 'quotes#index'
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
    super do
      if params[:line_item_group_name] && @quote.valid?
        @quote
          .default_group
          .update_attributes(name: params[:line_item_group_name])
      end
      # scrapping for now since freshdesk is a piece of shit
      # @quote.create_freshdesk_ticket(current_user) if Rails.env.production?
    end
  end

  def quote_select
    respond_to do |format|
      @quote_select_hash = {}
      @quote_select_hash[:quotes] = Quote.all
      @quote_select_hash[:index] = params[:index].to_i

      index = @quote_select_hash[:index]
      name = session[:prices][index][:name]
      unit_price = session[:prices][index][:prices][:base_price]

      @quote_select_hash[:new_line_item] = LineItem.new(name: name, unit_price: unit_price, description: 'Canned Description')

      format.js
    end
  end

  def stage_quote
    @quote = Quote.find(params[:quote_id])

    group = @quote.line_item_groups.first
    saved = group.line_items.new(name: params[:name],
                         unit_price: params[:total_price],
                         description: 'Canned Description',
                         quantity: 1).save

    if saved
      fire_activity(@quote, :added_line_item)
    else
      flash[:error] = 'The line item could not be added to the quote.'
    end

    redirect_to edit_quote_path params[:quote_id]
  end

  def email_customer
    @quote = Quote.find(params[:quote_id])

    email = Email.create(
        body: params[:email_body],
        subject: params[:email_subject],
        sent_from: current_user.email,
        sent_to: params[:email_recipients],
        cc_emails: params[:cc]
    )

    @quote.emails << email

    hash = {
      quote: @quote,
      body: params[:email_body],
      subject: params[:email_subject],
      from: current_user.email,
      to: params[:email_recipients],
      cc: params[:cc]
    }

    deliver_email(hash)

    redirect_to edit_quote_path params[:quote_id]
  end

  def populate_email_modal
    respond_to do |format|
      @quote = Quote.find(params[:quote_id])
      format.js
    end
  end

private

  def assign_new_quote_hash
    @new_quote_hash = {}

    assign = lambda do |key|
      @new_quote_hash[key] = params[key] if params[key]
    end

    assign[:price_information]
    assign[:line_item_group_name]

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

  def deliver_email(hash)
    begin
      QuoteMailer.delay.email_customer(hash)
      flash[:success] = 'Your email was successfully sent!'
      fire_activity(@quote, :emailed_customer)
    rescue Net::SMTPAuthenticationError,
           Net::SMTPServerBusy,
           Net::SMTPSyntaxError,
           Net::SMTPFatalError,
           Net::SMTPUnknownError => _e
      flash[:notice] = 'Your email was unable to be sent'
      flash[:success] = nil
      @activity = PublicActivity::Activity.find_by_trackable_id(params[:quote_id])
      @activity.destroy
    end
  end

  def permitted_params
    params.permit(quote: [
                   :email, :phone_number, :first_name, :last_name, :company,
                   :twitter, :name, :valid_until_date, :estimated_delivery_date,
                   :salesperson_id, :store_id, :shipping,
                    line_items_attributes: [
                     :name, :quantity, :taxable, :description, :id,
                     :imprintable_variant_id, :unit_price, :_destroy
                    ],
                    emails_attributes: [
                        :subject, :body, :sent_to, :sent_from, :cc_emails, :id, :_destroy
                    ]
                  ])
  end
end
