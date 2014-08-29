class ColorsController < InheritedResources::Base
  before_action :set_current_action

  def index
    super do
      @colors = Color.all.page(params[:page])
    end
  end

  def update
    super do |success, failure|
      success.html { redirect_to colors_path }
      failure.html { render :edit }
    end
  end

  def show
    super do |format|
      format.html { redirect_to edit_color_path params[:id] }
    end
  end

  protected

  def set_current_action
    @current_action = 'colors'
  end

  private

  def permitted_params
    params.permit(color: [:name, :sku, :retail])
  end
end
