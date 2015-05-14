class Comment < ActiveRecord::Base

  include ActsAsCommentable::Comment

  belongs_to :commentable, :polymorphic => true

  default_scope -> { order('created_at ASC') }

  # NOTE: install the acts_as_votable plugin if you
  # want user to vote on the quality of comments.
  #acts_as_voteable

  # NOTE: Comments belong to a user
  belongs_to :user

  def public
    role == 'public'
  end
  alias_method :public?, :public
  def public=(value)
    if value && value != 'false' && value != '0'
      self.role = 'public'
    else
      self.role = 'private'
    end
  end
end
