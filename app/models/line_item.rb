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

  scope :non_imprintable, -> { where imprintable_object_id: nil }
  scope :imprintable, -> { where.not imprintable_object_id: nil }
  scope :taxable, -> { where(taxable: true) }

  belongs_to :imprintable_object, polymorphic: true
  belongs_to :job, touch: true, inverse_of: :line_items

  validates :description, presence: true, unless: :imprintable?
  validates :name, presence: true, unless: :imprintable?
  validates :quantity, presence: true
  validates :quantity, greater_than_zero: true, if: :should_validate_quantity?
  validate  :quantity_is_not_negative, unless: :should_validate_quantity?
  validates :unit_price, presence: true, price: true, unless: :imprintable?
  validates :decoration_price, :imprintable_price, presence: true, price: true, if: :imprintable?
  validates :sort_order, presence: true, if: :markup_or_option?
  validates :imprintable_object_type, inclusion: {
    in: ['Imprintable', nil], message: 'must be "Imprintable"' }, if: :quote?
  validates :imprintable_object_type, inclusion: {
    in: ['ImprintableVariant', nil], message: 'must be "Imprintable Variant"' }, if: :order?
  validates :imprintable_object_id, uniqueness: {
    scope: [:job_id], message: 'is a duplicate in this group' }, if: :imprintable_and_in_job?

  before_validation :set_sort_order, if: :markup_or_option?
  after_update :enqueue_update_production_quantities, if: :order_in_production?
  after_save :recalculate_order_fields
  after_destroy :recalculate_order_fields

  def self.create_imprintables(job, imprintable, color, options = {})
    new_imprintables(job, imprintable, color, options)
      .each(&:save!)
  end

  def self.new_imprintables(job, imprintable, color, options = {})
    imprintable_variants = ImprintableVariant.size_variants_for(
      param_record_id(imprintable),
      param_record_id(color)
    )

    imprintable_variants.map do |variant|
      LineItem.new(
        imprintable_object_type: 'ImprintableVariant',
        imprintable_object_id:   variant.id,
        unit_price:         options[:base_unit_price].try(:to_f) || variant.imprintable.base_price || 0,
        quantity:           options[:quantity].try(:[], variant.size_id.to_s) || 0,
        job_id:             job.id,
        imprintable_price:  options[:imprintable_price] || variant.imprintable.base_price,
        decoration_price:   options[:decoration_price].try(:to_f) || 0,
      )
    end
  end

  %i(description name).each do |method|
    define_method(method) do
      imprintable? ? imprintable_object.send(method) : self[method] rescue ''
    end
  end

  def url
    super || imprintable.try(:supplier_link)
  end

  def order_in_production?
    order? && order.try(:production?)
  end

  def line_itemable
    job
  end
  def line_itemable=(new)
    self.job = new
  end
  def line_itemable_id
    job_id
  end
  def line_itemable_id=(new)
    self.job_id = new
  end
  def line_itemable_type
    'Job' unless job_id.nil?
  end
  def line_itemable_type=(new_type)
    return new_type if new_type == 'Job' || new_type.blank?
    raise "line_itemable has been changed to job. All code referencing line_itemable should be changed to reference job."
  end

  def imprintable_and_in_an_order?
    imprintable? && job.try(:jobbable_type) == 'Order'
  end

  def <=>(other)
    return super if imprintable_object_type == 'Imprintable'
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

  def quote?
    job.try(:jobbable_type) == 'Quote'
  end
  def order?
    job.try(:jobbable_type) == 'Order'
  end

  def order
    job.try(:order)
  end

  def imprintable
    if imprintable_object_type == 'Imprintable'
      imprintable_object
    else
      imprintable_object.try(:imprintable)
    end
  end

  def imprintable_id
    if imprintable_object_type == 'Imprintable'
      imprintable_object_id
    else
      imprintable_object.try(:imprintable_id)
    end
  end

  def imprintable_variant
    imprintable_object if imprintable_object_type == 'ImprintableVariant'
  end

  def imprintable_variant_id
    imprintable_object_id if imprintable_object_type == 'ImprintableVariant'
  end

  def imprintable_variant_id=(iv_id)
    self.imprintable_object_type = 'ImprintableVariant'
    self.imprintable_object_id = iv_id
  end
  def imprintable_variant=(iv)
    self.imprintable_object = iv
  end

  def imprintable_and_in_job?
    imprintable? && !(job_id.blank?)
  end

  def imprintable?
    !(imprintable_object_type.blank? || imprintable_object_id.blank?)
  end

  def imprintable_variant?
    !imprintable_object_id.blank? && imprintable_object_type == 'ImprintableVariant'
  end

  def size_display
    imprintable_variant.size.display_value rescue nil
  end

  def style_catalog_no
    imprintable.style_catalog_no if imprintable
  end

  def style_name
    imprintable.style_name if imprintable
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

  if Rails.env.production?
    def enqueue_update_production_quantities
      self.class.delay(queue: 'api').update_production_quantities(id)
    end
  else
    alias_method :enqueue_update_production_quantities, :update_production_quantities
  end

  def self.update_production_quantities(id)
    find(id).update_production_quantities
  end
  def update_production_quantities
    return unless order_in_production?
    return unless imprintable_variant

    new_count = job.imprintable_line_items_total
    errors = []

    job.imprints.each do |imprint|
      prod_imprint = imprint.production
      prod_imprint.count = new_count
      unless prod_imprint.save
        errors << "Imprint (prod##{prod_imprint.id}): #{prod_imprint.errors.full_messages.join(', ')}"
      end
    end

    unless errors.empty?
      order.issue_warning("Production API", errors.join("\n"))
    end
  end

  private

  def set_sort_order
    return unless sort_order.nil?

    if job && last_line_item = job.line_items.where.not(id: id).last
      last_sort_order = last_line_item.sort_order
    else
      last_sort_order = 0
    end

    self.sort_order = 1 + last_sort_order
  end

  def should_validate_quantity?
    return false if quantity == MARKUP_ITEM_QUANTITY

    job.try(:jobbable_type) == 'Quote' and imprintable? || quantity != MARKUP_ITEM_QUANTITY
  end

  def quantity_is_not_negative
    return if quantity == MARKUP_ITEM_QUANTITY

    if !quantity.nil? && quantity < 0
      errors.add :quantity, 'cannot be negative'
    end
  end

  def recalculate_order_fields
    if order
      order.recalculate_subtotal
      order.recalculate_taxable_total if taxable?
      order.save!
    end
  end
end
