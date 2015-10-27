class HomeController < ApplicationController
  def index
    @order_warnings = Order.search do 
      with(:warnings_count).greater_than 0 
      with(:salesperson_full_name,  current_user.full_name)
    end.results 
  end

  def undock
    if (@qr_id = params[:quote_request_id]) && session[:docked].is_a?(Array)
      session[:docked].delete_if { |qr| qr[:id].to_i == @qr_id.to_i }
    else
      session[:docked] = []
    end
  end
end
