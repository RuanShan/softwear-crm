module Customer
  class OrdersController < Customer::BaseController

    defaults finder: :find_by_customer_key

  end
end

