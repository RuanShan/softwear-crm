class OrdersController < InheritedResources::Base
  def update
    super do |success, failure|
      success.html { redirect_to orders_path }
      failure.html { redirect_to root_path }
    end
  end

  def create
    super do |success, failure|
      success.html do
        flash[:notice] = "Order successfully created!"
        redirect_to orders_path
      end
      failure.html do
        flash[:notice] = "Failed to create order."
        redirect_to edit_order_path(Order.new permitted_params)
      end
    end
  end

  def show
    redirect_to action: :edit
  end

private
  def permitted_params
    params.permit(order: [
      :email, :firstname, :lastname,
      :company, :twitter, :name, :po, 
      :in_hand_by, :terms, :tax_exempt,
      :tax_id_number, :is_redo, :redo_reason,
      :delivery_method, :phone_number, 
      :sales_status, :commmission_amount
    ])
  end
end
