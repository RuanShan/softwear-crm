class Imprintable < ActiveRecord::Base
  belongs_to :style
  has_one :brand, through: :style
  has_many :imprintable_variants
  has_many :colors, through: :imprintable_variants
  has_many :sizes, through: :imprintable_variants

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

  def get_iv(color,size)
    if Color.find_by_id(color.id)
      if Size.find_by_id(size.id)
        return true
      end
    end
    false
  end

  def find_variants
    variants = ImprintableVariant.find_by_sql("SELECT * FROM imprintable_variants AS iv
                                                  JOIN sizes
                                                  ON iv.size_id = sizes.id
                                                  WHERE imprintable_id = #{self.id}
                                                  ORDER BY color_id, sort_order")
  end
end
