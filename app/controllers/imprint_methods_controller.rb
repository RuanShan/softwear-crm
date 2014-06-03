class ImprintMethodsController < InheritedResources::Base

  def update
    super do |success, failure|
      success.html { redirect_to imprint_methods_path }
      failure.html { render action: :edit }
    end
  end

  def show
    super do |format|
      format.html { redirect_to edit_imprint_method_path params[:id] }
    end
  end

  private

   def permitted_params
    params.permit(imprint_method: [:name, :production_name])
  end
end