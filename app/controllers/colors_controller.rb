class ColorsController < InheritedResources::Base

  def update
    super do |format|
      format.html { redirect_to edit_color_path params[:id] }
    end
  end

  def show
    super do |format|
      format.html { redirect_to edit_color_path params[:id] }
    end
  end

  def create
    super do |format|
      format.html { redirect_to colors_path params }
    end
  end

  private

  def permitted_params
    params.permit(color: [:name, :sku])
  end
end
