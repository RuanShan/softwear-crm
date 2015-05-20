class CommentDrop < Liquid::Drop

  def initialize(comment)
    @comment = comment
  end

  def title
    @comment.name
  end

  def comment
    @comment.comment
  end
end

