class OrdersController < InheritedResources::Base

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

  def create
    params[:order][:in_hand_by] = Date.strptime(params[:order][:in_hand_by], '%m/%d/%Y %H:%M %p') if params[:order][:in_hand_by].length > 0
    super
  end

  private

  def permitted_params
    params.permit(order: [
      :email, :firstname, :lastname,
      :company, :twitter, :name, :po,
      :in_hand_by, :terms, :tax_exempt,
      :tax_id_number, :is_redo, :redo_reason,
      :delivery_method, :phone_number,
      :sales_status, :commission_amount,
      :store_id, :salesperson_id
    ])
  end

end
