class ImprintableVariantsController < InheritedResources::Base

  def update
    super do |format|
      format.html { redirect_to imprintable_variant_path params[:id] }
    end
  end

  def show
    super do |format|
      format.html { redirect_to edit_imprintable_variant_path[:id] }
    end
  end

  def create
    super do |format|
      format.html { redirect_to imprintable_invariants_path params }
    end
  end

  private

  def permitted_params
    params.permit(imprintable_invariant: [:imprintable_id, :size_id, :color_id])
  end
end