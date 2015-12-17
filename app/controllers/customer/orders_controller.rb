module Customer
  class OrdersController < Customer::BaseController

    defaults finder: :find_by_customer_key

    def show
      @order = Order.find_by(customer_key: params[:id])
    end

  end
end

