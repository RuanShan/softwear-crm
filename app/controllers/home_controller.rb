class HomeController < ApplicationController
  def index
  end

  def undock
    if (@qr_id = params[:quote_request_id]) && session[:docked].is_a?(Array)
      session[:docked].delete_if { |qr| qr[:id].to_i == @qr_id.to_i }
    else
      session[:docked] = []
    end
  end
end
