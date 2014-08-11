class LineItem < ActiveRecord::Base
  include TrackingHelpers
  extend ParamHelpers

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

  #TODO: ensure unless validations work after switching 
  #      from validates_presence_of to sexiness
  validates :description, presence: true, unless: :imprintable?
  validates :imprintable_variant_id, 
            uniqueness: {
              scope: [
                :line_itemable_id, :line_itemable_type
              ]
            }, if: :imprintable?
  validate :imprintable_variant_exists, if: :imprintable?
  validates :name, presence: true, unless: :imprintable?
  validates :quantity, presence: true
  validates :unit_price, presence: true

  def self.create_imprintables(line_itemable, imprintable, color, options = {})
    new_imprintables.each(&:save)
  end

  def self.new_imprintables(line_itemable, imprintable, color, options = {})
    imprintable_variants = ImprintableVariant.size_variants_for(
      param_record_id(imprintable),
      param_record_id(color)
    )

    imprintable_variants.map do |variant|
      LineItem.new(
        imprintable_variant_id: variant.id,
        unit_price: options[:base_unit_price] || 
                    variant.imprintable.base_price || 0,
        quantity: 0,
        line_itemable_id: line_itemable.id,
        line_itemable_type: line_itemable.class.name
      )
    end
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

  %i(name description).each do |method|
    define_method(method) do
      imprintable? ? imprintable_variant.send(method) : self[method]
    end
  end

  def imprintable
    imprintable_variant.imprintable
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

  def total_price
    unit_price && quantity ? unit_price * quantity : 'NAN'
  end

  private

  def imprintable_variant_exists
    if ImprintableVariant.where(id: imprintable_variant_id).size < 1
      errors.add :imprintable_variant, 'does not exist'
    end
  end
end
