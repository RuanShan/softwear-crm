Injectable.NonDeletable do
  default_scope -> { where(deleted_at: nil) }
  scope :deleted, -> { unscoped.where.not(deleted_at: nil) }

  def destroyed?
    !deleted_at.nil?
  end

  def destroy
    update_attribute(:deleted_at, Time.now)
  end

  def destroy!
    update_column(:deleted_at, Time.now)
  end
end