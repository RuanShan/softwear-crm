class LineItem < ActiveRecord::Base
  include TrackingHelpers
  extend ParamHelpers
  include Softwear::Lib::Enqueue

  MARKUP_ITEM_QUANTITY = -999

  acts_as_paranoid

  searchable do
    text :name, :description
    boolean(:is_imprintable) { imprintable? }
    integer :id
  end

  tracked skip_defaults: true

  default_scope { order(:sort_order) }

  scope :non_imprintable, -> { where imprintable_object_id: nil }
  scope :imprintable, -> { where.not imprintable_object_id: nil }
  scope :taxable, -> { where(taxable: true) }

  belongs_to :imprintable_object, polymorphic: true
  has_one :variant_imprintable, through: :imprintable_object, source: :imprintable
  belongs_to :job, touch: true, inverse_of: :line_items
  has_many :name_numbers, -> li { where(imprintable_variant_id: li.imprintable_object_id) }, through: :job

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
    in: ['ImprintableVariant', nil], message: 'must be "ImprintableVariant"' }, if: :order?
  validates :imprintable_object_id, uniqueness: {
    scope: [:job_id], message: 'is a duplicate in this group' }, if: :imprintable_and_in_job?

  validate :quantity_isnt_less_than_name_number_quantity, if: :order?

  before_validation :set_sort_order, if: :markup_or_option?
  enqueue :update_production_quantities, queue: 'api'
  after_update :enqueue_update_production_quantities, if: :order_in_production?
  after_save :recalculate_order_fields
  after_destroy :recalculate_order_fields


  def quantity_isnt_less_than_name_number_quantity
    return if name_numbers.empty?

    mismatch = job
      .mismatched_name_number_quantities(:<, add_line_items: self)
      .find { |m| m.variant.id == imprintable_object_id }

    if mismatch.present?
      errors.add(
        :quantity,
        "(#{quantity}) is less than the amount of name/numbers (#{mismatch.name_number_count}) "\
        "for #{imprintable_object.full_name}"
      )
    end
  end

  def self.in_need_of_cost_old_query
    fields = %w(
      li.id sum(li.quantity) li.imprintable_object_id iv.color_id iv.imprintable_id s.display_value
      s.name c.name o.id iv.last_cost_amount
    )
      .map
      .with_index { |f, i| [f, i] }
      .to_h

    <<-SQL
      select #{fields.keys.join(', ')} from line_items li

      join imprintable_variants iv on (iv.id = li.imprintable_object_id)
      join sizes  s  on (s.id = iv.size_id)
      join colors c  on (c.id = iv.color_id)
      join jobs   j  on (j.id = li.job_id)
      join orders o  on (o.id = j.jobbable_id)

      where li.imprintable_object_type = "ImprintableVariant"
      and j.jobbable_type = "Order"
      and o.deleted_at is null
      and iv.deleted_at is null
      and li.deleted_at is null
      and (
        not exists (
          select costs.id from costs
          where costs.costable_type = "LineItem"
          and   costs.costable_id = li.id
        )
        or
        exists (
          select costs.id from costs
          where costs.costable_type = "LineItem"
          and   costs.costable_id = li.id
          and   (costs.amount = 0 or costs.amount = null)
        )
      )

      group by iv.id
      order by o.id, s.sort_order

      limit 1000
    SQL
  end

  def self.in_need_of_cost_query
    fields = %w(
      li.id sum(li.quantity) li.imprintable_object_id iv.color_id iv.imprintable_id s.display_value
      s.name c.name o.id iv.last_cost_amount
    )
      .map
      .with_index { |f, i| [f, i] }
      .to_h

    <<-SQL
      select #{fields.keys.join(', ')} from line_items li

      join imprintable_variants iv on (iv.id = li.imprintable_object_id)
      join jobs   j on j.id = li.job_id
      join sizes  s  on (s.id = iv.size_id)
      join colors c  on (c.id = iv.color_id)
      join orders o  on (o.id = j.jobbable_id)

      left join costs co on (co.costable_id = li.id and co.costable_type = 'LineItem')
      where li.imprintable_object_id is not null
      and j.jobbable_type = 'Order'
      and o.deleted_at  is null
      and iv.deleted_at is null
      and li.deleted_at is null
      and co.id is null or co.amount = 0

      group by iv.id
      order by s.sort_order

      limit 1000
    SQL
  end

  def self.in_need_of_cost(limit = nil, offset = nil)
    fields = %w(
      li.id sum(li.quantity) li.imprintable_object_id iv.color_id iv.imprintable_id s.display_value
      s.name c.name o.id iv.last_cost_amount
    )
      .map
      .with_index { |f, i| [f, i] }
      .to_h

    sql_results = ActiveRecord::Base.connection.execute <<-SQL
      select #{fields.keys.join(', ')} from line_items li

      join imprintable_variants iv on (iv.id = li.imprintable_object_id)
      join jobs   j on j.id = li.job_id
      join sizes  s  on (s.id = iv.size_id)
      join colors c  on (c.id = iv.color_id)
      join orders o  on (o.id = j.jobbable_id)

      where li.imprintable_object_id is not null
      and (li.cost_amount is null or li.cost_amount = 0)
      and j.jobbable_type = 'Order'
      and o.deleted_at  is null
      and iv.deleted_at is null
      and li.deleted_at is null

      group by iv.id
      order by o.id, s.sort_order

      #{"limit  #{limit}"  if limit}
      #{"offset #{offset}" if offset}
    SQL

    if block_given? && limit && sql_results.size == limit
      yield limit
    end

    line_items_by_i_id = sql_results.map do |r|
      OpenStruct.new(
        id:             r[fields['li.id']],
        quantity:       r[fields['sum(li.quantity)']],
        imprintable_id: r[fields['iv.imprintable_id']],
        color_id:       r[fields['iv.color_id']],
        size_name:      r[fields['s.display_value']] || r[fields['s.name']],
        color_name:     r[fields['c.name']],
        last_cost:      r[fields['iv.last_cost_amount']],
        imprintable_variant_id: r[fields['li.imprintable_object_id']]
      )
    end
      .group_by(&:imprintable_id)

    imprintables = Imprintable.where(id: line_items_by_i_id.keys)

    line_items_by_imprintable = {}
    imprintables.each do |imprintable|
      line_items_by_imprintable[imprintable] = line_items_by_i_id[imprintable.id].group_by(&:color_id)
    end
    line_items_by_imprintable
  end

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
      imprintable_price = options[:imprintable_price].to_f || variant.imprintable.base_price.to_f
      upcharge_group    = variant.size.upcharge_group || 'base_price'
      upcharge          = variant.imprintable.send(upcharge_group)

      while (upcharge.nil? || upcharge.zero?) && upcharge_group =~ /^x+l/
        upcharge_group = upcharge_group[1..-1]
        upcharge_group = 'base_price' if upcharge_group == 'xl_price'
        upcharge = variant.imprintable.send(upcharge_group)
      end
      upcharge ||= 0

      imprintable_price += upcharge

      LineItem.new(
        imprintable_object_type: 'ImprintableVariant',
        imprintable_object_id:   variant.id,
        unit_price:         options[:base_unit_price].try(:to_f) || variant.imprintable.base_price || 0,
        quantity:           options[:quantity].try(:[], variant.size_id.to_s) || 0,
        job_id:             job.id,
        imprintable_price:  imprintable_price,
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

  def update_production_quantities
    return unless order_in_production?
    return unless imprintable_variant

    new_count = job.imprintable_line_items_total
    errors = []

    job.imprints.each do |imprint|
      prod_imprint = imprint.production
      next if prod_imprint.nil?

      unless prod_imprint.update_attribute(:count, new_count)
        errors << "Imprint (prod##{prod_imprint.id}): #{prod_imprint.errors.full_messages.join(', ')}"
      end
    end

    unless errors.empty?
      order.issue_warning("Production API", errors.join("\n"))
    end

  rescue
    raise unless Rails.env.development?
  end

  def identifier
    "#{imprintable_variant.brand.try(:name) || '<no brand>'} #{imprintable_variant.style_catalog_no}: #{imprintable_variant.color.name} #{imprintable_variant.size.display_value}"
  end

  def imprintable_and_color
    "#{imprintable_variant.brand.try(:name) || '<no brand>'} #{imprintable_variant.style_catalog_no}: #{imprintable_variant.color.name}"
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
    Order.without_tracking do
      if order
        order.recalculate_subtotal
        order.recalculate_taxable_total
        order.save!
      end
    end
  end
end
