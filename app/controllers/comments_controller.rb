class CommentsController < InheritedResources::Base
  belongs_to :quote, polymorphic: true, optional: true

  def create
    super do |format|
      byebug
      format.js
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
      :quote_id,
      comment: [
        :title, :comment, :public,
        :commentable_id, :commentable_type
      ]
    )
  end
end
