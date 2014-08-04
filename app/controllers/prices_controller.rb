class PricesController < ApplicationController
  def new
    respond_to do |format|
      @imprintable = Imprintable.find(params[:id])

      format.js
    end
  end

  def index
    respond_to do |format|
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
      session[:prices].delete_at(params[:id].to_i)

      # TODO: david, refactor this and destroy_all! use destroy.js.erb

      format.js { render 'create' }
    end
  end

  def destroy_all
    respond_to do |format|
      session[:prices] = []

      format.js { render 'create' }
    end
  end
end
