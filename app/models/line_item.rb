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

  def description
    if imprintable?
      imprintable_variant.description
    else
      read_attribute :description
    end
  end

private
  def imprintable_variant_exists
    if ImprintableVariant.where(id: imprintable_variant_id).count < 1
      errors.add :imprintable_variant, "Imprintable Variant does not exist"
    end
  end
end