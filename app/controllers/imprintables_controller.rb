class ImprintablesController < InheritedResources::Base

  def update
    super do |format|
      format.html { redirect_to edit_imprintable_path params[:id] }
    end
  end

  def show
    super do |format|
      format.html { redirect_to edit_imprintable_path params[:id] }
    end
  end

  def create
    super do |format|
      format.html { redirect_to imprintables_path params }
    end
  end

  def edit
    super do
      @sizes = Size.all
      @colors = Color.all
    end
  end

  private

  def permitted_params
    params.permit(imprintable: [:flashable, :polyester, :special_considerations, :style_id])
  end
end
