module NonDeleteable
  extend ActiveSupport::Concern

  included do
    inherit_resources
    default_scope -> { where(deleted_at: nil) }
  end

  def deleted?
    !deleted_at.nil?
  end

  def destroy
    update_attribute(:deleted_at, Time.now)
  end

  def destroy!
    update_column(:deleted_at, Time.now)
  end

  # methods defined here are going to extend the class, not the instance of it
  module ClassMethods

  end

end