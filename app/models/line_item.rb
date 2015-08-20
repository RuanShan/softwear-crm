class LineItem < ActiveRecord::Base
  include TrackingHelpers
  extend ParamHelpers

  MARKUP_ITEM_QUANTITY = -999

  acts_as_paranoid

  searchable do
    text :name, :description
    boolean(:is_imprintable) { imprintable? }
  end

  tracked skip_defaults: true

  default_scope { order(:sort_order) }

  scope :non_imprintable, -> { where imprintable_variant_id: nil }
  scope :imprintable, -> { where.not imprintable_variant_id: nil }

  belongs_to :imprintable_variant
  belongs_to :line_itemable, polymorphic: true, touch: true

  validates :description, presence: true, unless: :imprintable?
  validates :imprintable_variant_id,
            uniqueness: {
              scope: [:line_itemable_id, :line_itemable_type]
            }, if: :imprintable_and_in_an_order?
  validate :imprintable_variant_exists, if: :imprintable?
  validates :name, presence: true, unless: :imprintable?
  validates :quantity, presence: true
  validates :quantity, greater_than_zero: true, if: :should_validate_quantity?
  validate :quantity_is_not_negative, unless: :should_validate_quantity?
  validates :unit_price, presence: true, price: true, unless: :imprintable?
  validates :decoration_price, :imprintable_price, presence: true, price: true, if: :imprintable?
  validates :sort_order, presence: true, if: :markup_or_option?

  before_validation :set_sort_order, if: :markup_or_option?
  before_create :set_default_quantity

  def self.create_imprintables(line_itemable, imprintable, color, options = {})
    new_imprintables(line_itemable, imprintable, color, options)
      .each(&:save!)
  end

  def self.new_imprintables(line_itemable, imprintable, color, options = {})
    imprintable_variants = ImprintableVariant.size_variants_for(
      param_record_id(imprintable),
      param_record_id(color)
    )

    imprintable_variants.map do |variant|
      LineItem.new(
        imprintable_variant_id: variant.id,
        unit_price: options[:base_unit_price].to_f || variant.imprintable.base_price || 0,
        quantity: 0,
        line_itemable_id: line_itemable.id,
        line_itemable_type: line_itemable.class.name,
        imprintable_price: options[:imprintable_price] || variant.imprintable.base_price,
        decoration_price:  options[:decoration_price].to_f || 0,
      )
    end
  end

  %i(description name).each do |method|
    define_method(method) do
      imprintable? ? imprintable_variant.send(method) : self[method] rescue ''
    end
  end
  def name
    return super unless imprintable?

    if line_itemable.try(:jobbable_type) == 'Order'
      imprintable_variant.name
    else
      imprintable.try(:name)
    end
  end
  def description
    imprintable? ? imprintable.description : super rescue ''
  end

  def url
    super || imprintable.try(:supplier_link)
  end

  def imprintable_and_in_an_order?
    imprintable? && line_itemable.try(:jobbable_type) == 'Order'
  end

  def <=>(other)
    return 0 if other == self

    if imprintable?
      return -1 unless other.imprintable?

      imprintable_variant.size.sort_order <=>
        other.imprintable_variant.size.sort_order
    else
      return +1 if other.imprintable?

      name <=> other.name
    end
  end

  def order
    line_itemable.try(:order)
  end

  def imprintable
    imprintable_variant.try(:imprintable)
  end

  def imprintable_id
    imprintable_variant.try(:imprintable_id)
  end

  def imprintable?
    !imprintable_variant_id.nil?
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

  def unit_price
    if imprintable?
      decoration_price + imprintable_price
    else
      super
    end
  end

  def total_price
    unit_price && quantity ? unit_price * quantity : 'NAN'
  end

  def markup_hash(markup)
    hash = {}
    hash[:name] = markup.name
    hash[:description] = markup.description
    hash[:url] = markup.url
    hash[:unit_price] = markup.unit_price
    hash
  end

  def markup_or_option?
    quantity == MARKUP_ITEM_QUANTITY
  end
  alias_method :option_or_markup?, :markup_or_option?

  private

  def set_sort_order
    return unless sort_order.nil?

    if line_itemable && last_line_item = line_itemable.line_items.where.not(id: id).last
      last_sort_order = last_line_item.sort_order
    else
      last_sort_order = 0
    end

    self.sort_order = 1 + last_sort_order
  end

  def imprintable_variant_exists
    if ImprintableVariant.where(id: imprintable_variant_id).size < 1
      errors.add :imprintable_variant, 'does not exist'
    end
  end

  def set_default_quantity
    self.quantity = 1 if self.quantity.to_i == 0
  end

  def should_validate_quantity?
    return false if quantity == MARKUP_ITEM_QUANTITY

    line_itemable.try(:jobbable_type) == 'Quote' and imprintable? || quantity != MARKUP_ITEM_QUANTITY
  end

  def quantity_is_not_negative
    return if quantity == MARKUP_ITEM_QUANTITY

    if !quantity.nil? && quantity < 0
      errors.add :quantity, 'cannot be negative'
    end
  end
end
