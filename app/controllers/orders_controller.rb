class OrdersController < InheritedResources::Base
  def update
    super do |success, failure|
      success.html { redirect_to orders_path }
      failure.html { redirect_to root_path }
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
      :delivery_method, :phone_number
    ])
  end
end
