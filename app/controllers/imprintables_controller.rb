class ImprintablesController < InheritedResources::Base

  def update
    super do |format|
      format.html { redirect_to imprintables_path }
    end
  end

  def show
    super do |format|
      format.html { redirect_to edit_imprintable_path params[:id] }
    end
  end

  def create
    super do |format|
      format.html { redirect_to imprintables_path }
    end
  end

  private

  def permitted_params
    params.permit(imprintable: [:name, :catalog_number, :description])
  end
end
