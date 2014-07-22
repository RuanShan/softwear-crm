class QuotesController < InheritedResources::Base
  before_filter :format_times, only: [:create, :update]

  def new
    super do
      @quote.line_items.build
      @current_user = current_user
    end
  end

  def edit
    super do
      @current_user = current_user
    end
  end

  def show
    super do |format|
      format.json do
        render json: {
            result: 'success',
            content: render_string(partial: 'edit_form', locals: { quote: @quote })
        }
      end
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
