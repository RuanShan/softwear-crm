class StylesController < InheritedResources::Base

  def update
    super do |format|
      format.html { redirect_to styles_path }
    end
  end

  def show
    super do |format|
      format.html { redirect_to edit_style_path params[:id] }
    end
  end

  private

  def permitted_params
    params.permit(style: [:name, :catalog_no, :description, :sku, :brand_id])
  end
end
