class Comment < ActiveRecord::Base
  include Softwear::Auth::BelongsToUser
  include ActsAsCommentable::Comment
  include TrackingHelpers

  tracked by_current_user + { recipient: ->(view, comment) { comment.commentable } }

  belongs_to :commentable, :polymorphic => true

  default_scope -> { order('created_at ASC') }
  scope :public_comments, -> { where role: 'public' }


  # NOTE: install the acts_as_votable plugin if you
  # want user to vote on the quality of comments.
  #acts_as_voteable

  belongs_to_user

  def name
    title
  end

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
