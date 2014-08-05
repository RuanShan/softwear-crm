class LineItem < ActiveRecord::Base
  include TrackingHelpers

  acts_as_paranoid

  searchable do
    text :name, :description
    boolean(:is_imprintable) { imprintable? }
  end

  scope :non_imprintable, -> { where imprintable_variant_id: nil }
  scope :imprintable, -> { where.not imprintable_variant_id: nil }

  tracked skip_defaults: true

  belongs_to :imprintable_variant
  belongs_to :line_itemable, polymorphic: true
  has_one :order, through: :job

  #TODO: ensure unless validations work after switching from validates_presence_of to sexiness
  validates :description, presence: true, unless: :imprintable?
  validates :imprintable_variant_id, uniqueness: { scope: [:line_itemable_id, :line_itemable_type] }, if: :imprintable?
  validate :imprintable_variant_exists, if: :imprintable?
  validates :name, presence: true, unless: :imprintable?
  validates :quantity, presence: true
  validates :unit_price, presence: true

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

  def imprintable
    imprintable_variant.imprintable
  end

  #TODO: should it be unless rather than != nil?
  def imprintable?
    imprintable_variant_id != nil
  end

  def size_display
    imprintable_variant.size.display_value
  end

  def style_catalog_no
    imprintable_variant.imprintable.style_catalog_no
  end

  def style_name
    imprintable_variant.imprintable.style_name
  end

  def total_price
    # TODO: look into refactoring
    if unit_price && quantity
      unit_price * quantity
    else
      'NAN'
    end
  end

  private

  def imprintable_variant_exists
    if ImprintableVariant.where(id: imprintable_variant_id).size < 1
      errors.add :imprintable_variant, 'does not exist'
    end
  end
end
