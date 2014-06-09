class ImprintableVariant < ActiveRecord::Base
  default_scope -> { where(deleted_at: nil)}
  scope :deleted, -> { unscoped.where.not(deleted_at: nil)}

  belongs_to :imprintable
  belongs_to :size
  belongs_to :color

  validates :imprintable, presence: true
  validates :size, presence: true
  validates :color, presence: true

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
