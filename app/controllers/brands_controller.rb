class BrandsController < InheritedResources::Base
  before_action :set_current_action

  def index
    super do
      @brands = Brand.all.page(params[:page])
    end
  end

  def update
    super do |success, failure|
      success.html { redirect_to brands_path }
      failure.html { render action: :edit }
    end
  end

  def show
    super do |format|
      format.html { redirect_to edit_brand_path params[:id] }
    end
  end

  protected

  def set_current_action
    @current_action = 'brands'
  end

  private

  def permitted_params
    params.permit(brand: [:name, :sku, :retail])
  end
end
