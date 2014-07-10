class OrdersController < InheritedResources::Base
  before_filter :format_time, only: [:create, :update]

  def index
    super do
      @orders = Order.all.page(params[:page])
    end
  end

  def update
    super do |success, failure|
      success.html { redirect_to edit_order_path(params[:id])+'#details' }
      failure.html { render action: :edit, anchor: 'details' }
    end
  end

  def show
    redirect_to action: :edit
  end

  def new
    super do
      @current_user = current_user
      stores = Store.all
      if stores.empty?
        @empty = true
      else
        @empty = false
      end
    end
  end

  private

  def format_time
    begin
      time = DateTime.strptime(params[:order][:in_hand_by], '%m/%d/%Y %H:%M %p').to_time unless (params[:order].nil? or params[:order][:in_hand_by].nil?)
      offset = (time.utc_offset)/60/60
      adjusted_time = (time - offset.hours).utc
      params[:order][:in_hand_by] = adjusted_time
    rescue ArgumentError
      params[:order][:in_hand_by]
    end
  end

  def permitted_params
    params.permit(order: [
      :email, :firstname, :lastname,
      :company, :twitter, :name, :po,
      :in_hand_by, :terms, :tax_exempt,
      :tax_id_number, :redo_reason,
      :delivery_method, :phone_number,
      :sales_status, :commission_amount,
      :store_id, :salesperson_id, :total
    ])
  end

end
