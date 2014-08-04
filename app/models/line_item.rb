class LineItem < ActiveRecord::Base
  include TrackingHelpers

  belongs_to :line_itemable, polymorphic: true
  belongs_to :imprintable_variant
  has_one :order, through: :job

  # TODO: 'sexy' validator
  validates_presence_of :unit_price
  validates_presence_of :quantity
  validates_presence_of :name, unless: :imprintable?
  validates_presence_of :description, unless: :imprintable?
  validate :imprintable_variant_exists, if: :imprintable?
  validates :imprintable_variant_id, uniqueness: { scope: [:line_itemable_id, :line_itemable_type] }, if: :imprintable?

  acts_as_paranoid
  tracked skip_defaults: true

  scope :non_imprintable, -> { where imprintable_variant_id: nil }
  scope :imprintable, -> { where.not imprintable_variant_id: nil }

  searchable do
    text :name, :description
    boolean(:is_imprintable) { imprintable? }
  end

  def total_price
    # TODO: look into refactoring
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

  def style_name
    imprintable_variant.imprintable.style_name
  end

  def style_catalog_no
    imprintable_variant.imprintable.style_catalog_no
  end

  %i(name description).each do |method|
    define_method(method) do
      # TODO: ternary
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
    # TODO: refactor
    return 0 if other == self
    if imprintable?
      unless other.imprintable?
        return -1
      end
      imprintable_variant.size.sort_order <=> other.imprintable_variant.size.sort_order
    else
      if other.imprintable?
        return +1
      end
      name <=> other.name
    end
  end

  private

  def imprintable_variant_exists
    if ImprintableVariant.where(id: imprintable_variant_id).size < 1
      errors.add :imprintable_variant, 'does not exist'
    end
  end
end
