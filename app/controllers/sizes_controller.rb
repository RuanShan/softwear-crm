class SizesController < InheritedResources::Base

  def update
    super do |format|
      format.html { redirect_to sizes_path }
    end
  end

  def show
    super do |format|
      format.html { redirect_to edit_size_path params[:id] }
    end
  end

  # def create
  #   super do |format|
  #     format.html { redirect_to sizes_path params[:id] }
  #   end
  # end

  private

  def permitted_params
    params.permit(size: [:name, :display_value, :sku, :sort_order])
  end
end
