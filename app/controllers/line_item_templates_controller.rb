class LineItemTemplatesController < InheritedResources::Base
  before_filter :sales_manager_only, only: [:create, :update, :destroy, :edit]

  def index
    if (query = params[:q])
      @line_item_templates = LineItemTemplate.search do
        fulltext query
      end
        .results

      if params[:respond_with_partial]
        respond_to do |format|
          format.js do
            render partial: params[:respond_with_partial],
                   locals: { line_item_templates: @line_item_templates }
          end
        end
      end
    else
      super
    end
  end

  def show
    redirect_to action: :edit
  end

  private

  def line_item_template_params
    params.require(:line_item_template).permit(:name, :description, :url, :unit_price)
  end
end
