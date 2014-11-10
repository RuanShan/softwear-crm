class PricesController < ApplicationController
  respond_to :js

  def new
    respond_to do |format|
      @imprintable = Imprintable.find(params[:id])

      format.js
    end
  end

  # session[:prices] == {
  #   pricing_group_1: [
  #     { pricing_hash_1 },
  #     { pricing_hash_2 }
  #   ],
  #     pricing_group_2: [
  #       { pricing_hash_3 },
  #       ...
  #     ],
  #     ...
  # }
  def create
    respond_to do |format|
      if params[:pricing_group].nil?
        flash[:error] = 'Pricing group cannot be empty'
        return
      end
      @imprintable = Imprintable.find(params[:id])
      session[:prices] = {} unless session[:prices].is_a? Hash
      pricing_group_sym = params[:pricing_group].to_sym
      pricing_group_array = session[:prices][pricing_group_sym]
      pricing_hash = @imprintable.pricing_hash(params[:decoration_price].to_f)
      pricing_group_array << pricing_hash
#     merge the new pricing_group over the old one
      session[:prices][pricing_group_sym].merge!

      format.js
    end
  end

  def index
    respond_to do |format|
      session[:prices] = {} unless session[:prices].is_a? Hash
      format.js
    end
  end

  def destroy
    respond_to do |format|
      session[:prices].delete_at(params[:id].to_i)
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
