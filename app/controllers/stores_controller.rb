class StoresController < InheritedResources::Base
  def update
    super do |format|
      format.html { redirect_to stores_path }
    end
  end

  def show
    super do |format|
      format.html { redirect_to stores_path }
    end
  end

  private

  def permitted_params
    params.permit(store: [:name])
  end
end
