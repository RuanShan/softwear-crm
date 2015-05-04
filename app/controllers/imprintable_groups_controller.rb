class ImprintableGroupsController < InheritedResources::Base
  def show
    redirect_to action: :index
  end

  private

  def permitted_params
    params.permit(imprintable_group: [:name])
  end
end
