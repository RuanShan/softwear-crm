class ColorsController < InheritedResources::Base

  def index
    super do
      @colors = Color.all.page(params[:page])
    end
  end

  def update
    super do |success, failure|
      success.html { redirect_to colors_path }
      failure.html { render action: :edit }
    end
  end

  def show
    super do |format|
      format.html { redirect_to edit_color_path params[:id] }
    end
  end

  private

  def permitted_params
    params.permit(color: [:name, :sku, :retail])
  end
end
