class PricesController < ApplicationController
  respond_to :js

  def new
    respond_to do |format|
      @imprintable = Imprintable.find(params[:id])

      format.js
    end
  end

  def create
    respond_to do |format|
      @imprintable = Imprintable.find(params[:id])
      session[:prices] = [] unless session[:prices].is_a? Array
      session[:prices] << @imprintable.pricing_hash(params[:decoration_price].to_f)

      format.js
    end
  end

  def destroy
    respond_to do |format|
      if params[:destroy_all].nil?
        session[:prices].delete_at(params[:id].to_i)
      else
        session[:prices] = []
      end

      format.js { render 'create' }
    end
  end
end
