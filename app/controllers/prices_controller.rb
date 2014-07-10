class PricesController < ApplicationController
  include PricingModule

  def new
    respond_to do |format|
      @imprintable = Imprintable.find(params[:id])
      format.js
    end
  end

  def create
    respond_to do |format|
      @imprintable = Imprintable.find(params[:id])
      @prices_hash = get_prices(@imprintable, params[:decoration_price].to_f)
      format.js
    end
  end
end
