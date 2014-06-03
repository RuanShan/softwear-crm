class LineItem < ActiveRecord::Base
  belongs_to :job
  belongs_to :imprintable_variant

  validates_presence_of :name, unless: :imprintable?
  validates_presence_of :description, unless: :imprintable?
  validate :imprintable_variant_exists, if: :imprintable?

  inject NonDeletable

  def price; unit_price * quantity; end

  def imprintable?
    imprintable_variant_id != nil
  end

  def imprintable
    imprintable_variant.imprintable
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
      errors.add :imprintable_variant, "Imprintable Variant does not exist"
    end
  end
end