class ImprintMethod < ActiveRecord::Base

  validates_presence_of :name, :production_name
  validates_uniqueness_of :production_name, { scope: :name }

  default_scope -> { where(deleted_at: nil) }
  scope :deleted, -> { unscoped.where.not(deleted_at: nil)}

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
