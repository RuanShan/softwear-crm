class ImprintableGroupsController < InheritedResources::Base
  def show
    super do |format|
      format.html { redirect_to action: :index }
      format.js
    end
  end

  private

  def permitted_params
    params.permit(
      :imprintable_imprintable_groups_attributes,

      imprintable_group: [
        :name, :description,
        imprintable_imprintable_groups_attributes: [
          :id, :imprintable_id, :tier, :default, :_destroy,
          :imprintable_group_id
        ]
      ]
    )
  end
end
