class LineItemGroupsController < InheritedResources::Base
  belongs_to :quote, shallow: true
  respond_to :js

  # def update
  #   super do |format|
  #     format.js
  #   end
  # end

  # def create
  #   super do |format|
  #     format.js
  #   end
  # end

  private

  def permitted_params
    params.permit(
      :quote_id, :id,

      line_item_group: [:name, :description]
    )
  end
end
