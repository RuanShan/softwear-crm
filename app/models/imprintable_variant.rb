class ImprintableVariant < ActiveRecord::Base
  belongs_to :imprintable
  belongs_to :size
  belongs_to :color

  validates_presence_of :imprintable, :size, :color

  default_scope -> { where(deleted_at: nil)}
  scope :deleted, -> { unscoped.where.not(deleted_at: nil)}

  def full_name
    "#{imprintable.brand.name} #{imprintable.style.catalog_no} #{size.name} #{color.name}"
  end

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
