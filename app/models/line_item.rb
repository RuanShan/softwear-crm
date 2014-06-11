class LineItem < ActiveRecord::Base
  belongs_to :job
  belongs_to :imprintable_variant

  validates_presence_of :unit_price
  validates_presence_of :quantity
  validates_presence_of :name, unless: :imprintable?
  validates_presence_of :description, unless: :imprintable?
  validate :imprintable_variant_exists, if: :imprintable?
  validates :imprintable_variant_id, uniqueness: { scope: :job_id }, if: :imprintable?

  inject NonDeletable

  scope :non_imprintable, -> { where imprintable_variant_id: nil }
  scope :imprintable, -> { where.not imprintable_variant_id: nil }

  def price
    if unit_price && quantity
      unit_price * quantity
    else
      'NAN'
    end
  end

  def imprintable?
    imprintable_variant_id != nil
  end

  def imprintable
    imprintable_variant.imprintable
  end

  def style
    imprintable_variant.imprintable.style
  end

  [:name, :description].each do |method|
    define_method(method) do
      if imprintable?
        imprintable_variant.send method
      else
        read_attribute method
      end
    end
  end

  def size_display
    imprintable_variant.size.display_value
  end

  def <=>(other)
    return 0 if other == self
    if imprintable?
      unless other.imprintable?
        return -1
      end
      self.imprintable_variant.size.sort_order <=> other.imprintable_variant.size.sort_order
    else
      if other.imprintable?
        return +1
      end
      self.name <=> other.name
    end
  end

private
  def imprintable_variant_exists
    if ImprintableVariant.where(id: imprintable_variant_id).count < 1
      errors.add :imprintable_variant, "does not exist"
    end
  end
end