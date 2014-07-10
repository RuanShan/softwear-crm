class OrdersController < InheritedResources::Base

  def index
    super do
      @orders = Order.all.page(params[:page])
    end
  end

  def update
    params[:order][:in_hand_by] = DateTime.strptime(params[:order][:in_hand_by], '%m/%d/%Y %H:%M %p') if params[:order][:in_hand_by].length > 0
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

  def edit
    super do
      # Grab all activities associated with this order
      @activities = PublicActivity::Activity.all.limit(100).order('created_at DESC').select do |activity|
        if activity.trackable
          if activity.trackable_type == Order.name
            activity.trackable.id == @order.id
          elsif activity.trackable.respond_to? :order
            activity.trackable.order.id == @order.id
          elsif activity.trackable.respond_to? :orders
            activity.trackable.orders.any? { |o| o.id == @order.id }
          end
        end
      end
    end
  end

  def create
    params[:order][:in_hand_by] = DateTime.strptime(params[:order][:in_hand_by], '%m/%d/%Y %H:%M %p') if params[:order][:in_hand_by].length > 0
    super
  end

  private

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
