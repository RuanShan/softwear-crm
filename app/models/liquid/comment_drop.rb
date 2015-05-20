class CommentDrop < Liquid::Drop

  def initialize(comment)
    @comment = comment
  end

  def title
    @comment.title
  end

  def comment
    @comment.comment
  end
end

