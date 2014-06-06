class Imprintable < ActiveRecord::Base

  belongs_to :style
  has_one :brand, through: :style
  has_many :imprintable_variants
  has_many :colors, through: :imprintable_variants
  has_many :sizes, through: :imprintable_variants

  attr_accessor :valid_imprintable_variants_count

  validates_presence_of :style

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

  def name
    "#{style.catalog_no} #{style.name}"
  end

  def find_variants
    if self.id
      ImprintableVariant.includes(:size, :color).where("imprintable_id = #{self.id}")
    else
      []
    end
  end
end
