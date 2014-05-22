class ColorsController < InheritedResources::Base

  def update
    super do |format|
      format.html { redirect_to colors_path }
    end
  end

  def show
    super do |format|
      format.html { redirect_to edit_color_path params[:id] }
    end
  end

  # adding this in will make it so that the controller will redirect
  # to the table view after a user creates a color.
  # the reason why its left out is because if a user were to create
  # a duplicate color that isn't allowed, he would miss the error
  # message that appears, i wasn't able to get it working but i
  # might revisit

  # def create
  #   super do |format|
  #     format.html { redirect_to colors_path params[:id] }
  #   end
  # end

  private

  def permitted_params
    params.permit(color: [:name, :sku])
  end
end
