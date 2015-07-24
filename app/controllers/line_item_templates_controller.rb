class LineItemTemplatesController < InheritedResources::Base
  def show
    redirect_to action: :edit
  end

  private

  def line_item_template_params
    params.require(:line_item_template).permit(:name, :description, :url, :unit_price)
  end
end
