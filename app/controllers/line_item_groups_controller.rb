class LineItemGroupsController < InheritedResources::Base
  belongs_to :quote, shallow: true
  respond_to :js

  def update
    super do |format|
      format.js
      format.json do
        render json: { result: @line_item_group.valid? ? 'success' : 'failure' }
      end
    end
  end

  # def create
  #   super do |format|
  #     format.js
  #   end
  # end

  def show
    super do |format|
      format.json do
        render json: {
          result: 'success',
          content: render_string(
            partial: 'line_items',
            locals: { line_item_group: @line_item_group }
          )
        }
      end
    end
  end

  private

  def permitted_params
    params.permit(
      :quote_id, :id, :authenticity_token,

      line_item_group: [:name, :description]
    )
  end
end
