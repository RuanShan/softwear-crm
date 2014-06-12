class ImprintMethodsController < InheritedResources::Base
  respond_to :js, only: [:show]

  def update
    super do |success, failure|
      success.html { redirect_to imprint_methods_path }
      failure.html { render action: :edit }
    end
  end

  def show
    super do |format|
      format.html { redirect_to edit_imprint_method_path params[:id] }
      format.js { render }
    end
  end

  private

   def permitted_params
    params.permit(imprint_method: [:name, :production_name, ink_colors_attributes: [:name, :imprint_method_id, :id, :_destroy], print_locations_attributes: [:name, :max_height, :max_width, :imprint_method_id, :id, :_destroy]])
  end
end