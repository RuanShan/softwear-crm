class PricesController < ApplicationController
  respond_to :js

  def new
    respond_to do |format|
      session[:pricing_groups] = {} unless session[:pricing_groups].is_a? Hash
      @imprintable = Imprintable.find(params[:id])

      format.js
    end
  end

  # session[:pricing_groups] == {
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
      if params[:pricing_group_select].blank? && params[:pricing_group_text].blank?
        flash[:error] = 'Pricing group cannot be empty'
        return
      end

      @imprintable = Imprintable.find(params[:id])
      session[:pricing_groups] = {} unless session[:pricing_groups].is_a? Hash
      pricing_group_key = ''
      pricing_group_key = params[:pricing_group_text].to_sym unless params[:pricing_group_text].blank?
      pricing_group_key = params[:pricing_group_select].to_sym unless params[:pricing_group_select].blank?
      # if pricing_groups[pricing_group_key] is null, then make it an array
      session[:pricing_groups][pricing_group_key] ||= []
      pricing_hash = @imprintable.pricing_hash(params[:decoration_price].to_f)
      session[:pricing_groups][pricing_group_key] << pricing_hash

      format.js
    end
  end

  def index
    respond_to do |format|
      session[:pricing_groups] = {} unless session[:pricing_groups].is_a? Hash
      format.js
    end
  end

  def destroy
    respond_to do |format|
      key = params[:key].to_sym
      id = params[:id].to_i
      session[:pricing_groups][key].delete_at(id)
      session[:pricing_groups].delete(key) if session[:pricing_groups][key].size == 0
      format.js { render 'create' }
    end
  end

  def destroy_all
    respond_to do |format|
      session[:pricing_groups] = {}
      format.js { render 'create' }
    end
  end
end
