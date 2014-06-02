class BrandsController < InheritedResources::Base

  def update
    super do |format|
      format.html { redirect_to brands_path }
    end
  end

  def show
    super do |format|
      format.html { redirect_to edit_brand_path params[:id] }
    end
  end

  def create
    super do |format|
      format.html { redirect_to brands_path params }
    end
  end

  private

  def permitted_params
    params.permit(brand: [:name, :sku])
  end
end
