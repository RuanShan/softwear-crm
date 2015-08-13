class CommentsController < InheritedResources::Base
  belongs_to :quote, polymorphic: true, optional: true

  def create
    super do |success, failure|
      success.js
      failure.js { @failed = true }
    end
  end

  def destroy
    super do |format|
      format.js
    end
  end

  private

  def permitted_params
    params.permit(
      :quote_id, :order_id,
      comment: [
        :title, :comment, :public,
        :commentable_id, :commentable_type
      ]
    )
  end
end
