class PlatenHoopsController < InheritedResources::Base
  before_action :set_current_action

  def show
    super do |format|
      format.html { redirect_to edit_platen_hoop_path params[:id] }
    end
  end

  def update
    super do |success, failure|
      success.html { redirect_to platen_hoops_path }
      failure.html { render action: :edit }
    end
  end

  protected

  def set_current_action
    @current_action = 'platen_hoops'
  end

  private

  def permitted_params
    params.permit(platen_hoop: [:name, :max_width, :max_height])
  end
end
