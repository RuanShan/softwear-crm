class ImprintableVariantsController < InheritedResources::Base

  def update
    super do |format|
      format.html { redirect_to imprintable_variants_path }
    end
  end

  def show
    super do |format|
      format.html { redirect_to edit_imprintable_variants_path[:id] }
    end
  end

  def create
    super do |format|
      format.html { redirect_to imprintable_invariants_path }
    end
  end

  private

  def permitted_params
    params.permit(imprintable_invariant: [:imprintable_id, :weight, :deleted_at])
  end
end