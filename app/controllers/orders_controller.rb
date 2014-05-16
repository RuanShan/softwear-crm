class OrdersController < InheritedResources::Base
  def update
    super do |format|
      format.html { redirect_to edit_order_path params[:id] }
    end
  end

  def create
    ##
    # TODO
    super # Ask Ricky for help on this one
    # It doesn't redirect the same as the 
    # shipping methods one and therefore 
    # doesn't show the error message(s)
    # despite rendering it in the view
    ##

    # super do |success, failure|
    #   success.html do
    #     redirect_to edit_order_path # 
    #   end
    #   failure.html do
    #     redirect_to new_order_path
    #   end
    # end
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
      :sales_status, :commission_amount
    ])
  end
end
