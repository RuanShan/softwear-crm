class StylesController < InheritedResources::Base

  def index
    super do
      @styles = Style.all.page(params[:page])
    end
  end

  def update
    super do |success, failure|
      success.html { redirect_to styles_path }
      failure.html { render action: :edit }
    end
  end

  def show
    super do |format|
      format.html { redirect_to edit_style_path params[:id] }
    end
  end

  private

  def permitted_params
    params.permit(style: [:name, :catalog_no, :description, :sku, :brand_id, :retail])
  end
end
