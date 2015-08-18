class Job < ActiveRecord::Base
  include TrackingHelpers

  acts_as_paranoid

  searchable do
    text :name, :description
    string :name
    reference :jobbable
  end

  tracked by_current_user + on_order

  before_destroy :check_for_line_items
  after_update :destroy_self_if_line_items_and_imprints_are_empty

  belongs_to :jobbable, polymorphic: true
  has_many :artwork_request_jobs
  has_many :artwork_requests, through: :artwork_request_jobs
  has_many :colors, -> {readonly}, through: :imprintable_variants
  has_many :imprints, dependent: :destroy
  has_many :imprintables, -> {readonly}, through: :imprintable_variants
  has_many :imprintable_variants, -> {readonly}, through: :line_items
  has_many :line_items, as: :line_itemable, dependent: :destroy 
  has_many :shipments, as: :shippable

  accepts_nested_attributes_for :line_items, :imprints, allow_destroy: true

  Imprintable::TIERS.each do |tier_num, tier|
    tier_line_items = "#{tier.underscore}_line_items".to_sym

    has_many tier_line_items, -> { where tier: tier_num }, as: :line_itemable, class_name: 'LineItem'
    accepts_nested_attributes_for tier_line_items, allow_destroy: true
  end

  validate :assure_name_and_description, on: :create
  validates :name, uniqueness: { scope: [:jobbable_id] }, if: -> { jobbable_type == 'Order' }

  def imprintable_line_items_for_tier(tier)
    send(tier_line_items_sym(tier))
  end

  def self.tier_line_items_sym(tier)
    (
      (tier.is_a?(String) ? tier : Imprintable::TIERS[tier]).underscore +
      '_line_items'
    )
      .to_sym
  end
  def tier_line_items_sym(tier)
    Job.tier_line_items_sym(tier)
  end

  # NOTE this works together with javascripts/quote_line_items.js to achieve
  # dragging and dropping between jobs/tiers easily.
  #
  def self.assign_line_items_attributes_proc(tier_num = nil)
    proc do |attrs|
      attrs.each do |key, line_item_attributes|
        if line_item_attributes[:id]
          line_item = LineItem.unscoped.find(line_item_attributes[:id])
          if (d = line_item_attributes[:_destroy]) && !['false', '0'].include?(d)
            line_item.destroy
          else
            line_item.update_attributes(line_item_attributes)
          end
        else
          line_item = LineItem.new(line_item_attributes)
          line_item.line_itemable = self
          line_item.tier = tier_num if tier_num
          line_item.save
        end
      end
    end
  end

  Imprintable::TIERS.each do |tier_num, tier_name|
    # e.g. :good_line_items
    line_items_sym = tier_line_items_sym(tier_name)

    # e.g. def good_line_items_attributes=(attrs) ...
    define_method(
      "#{line_items_sym}_attributes=",
      &assign_line_items_attributes_proc(tier_num)
    )
  end
  define_method('line_items_attributes=', &assign_line_items_attributes_proc)

  # For on_order activity tracking helper
  def order
    return jobbable if jobbable_type == 'Order'
  end

  def imprintable_info
    colors, style_names, style_catalog_nos = [], [], []
    sorted_line_items = self.sort_line_items

    unless sorted_line_items.empty?
      sorted_line_items.each do |_imprintable_name, by_color|
        by_color.each do |color_name, line_items|
          colors            << color_name
          style_names       << line_items.first.style_name
          style_catalog_nos << line_items.first.style_catalog_no
        end
      end
    end

    colors.zip(style_names, style_catalog_nos)
      .map { |array| array.join(' ') }.join(', ')
  end

  def imprintable_variant_count
    return 0 if line_items.empty?
    line_items
      .map { |li| li.imprintable_variant_id ? li.quantity : 0 }
      .reduce(0, :+)
  end

  def max_print_area(print_location)
    #
    # Okay, here are 3 possibilities for implementation. First, my (Nigel's)
    # initial refactoring (which will remain uncommented for now):
    # ----------------------------------
    max_print = method(:max_print).to_proc.curry.(print_location)
    return max_print.(:width), max_print.(:height)

    # Currying is a little weird/inelegant in Ruby, so it looks kinda
    # funky, but it is DRY and fairly concise.

    # Here's the original implementation:
    # ----------------------------------
    # width = (imprintables.map(&:max_imprint_width) << print_location.max_width).map(&:to_f).min
    # height = (imprintables.map(&:max_imprint_height) << print_location.max_height).map(&:to_f).min
    # return width, height

    # Seems redundant and hard to indent cleanly, but easier to understand
    # if you aren't familiar with functional programming.
    # Here's another potential solution I came up with:
    # (Assuming no actual max_print method exists)
    # ----------------------------------
    # max_print = lambda do |width_or_height|
    #  (
    #    imprintables.map(&"max_imprint_#{width_or_height}".to_sym) +
    #    [print_location.send("max_#{width_or_height}")]
    #  )
    #    .map(&:to_f).min
    # end
    # return max_print.(:width), max_print.(:height)

    # This defines max_print inside this method, allowing direct access to
    # the print_location argument, meaning no need to curry or repeat
    # ourselves. I am unsure, however, if inner methods like this are
    # considered good practice (seems fine to me but we know how much that
    # weighs).
    #
    # Additionally, we should discuss the use of #() vs #call on procs.
    # The style guide insists on using #call always, and while I definitely
    # understand the clarity of #call, and I usually use it, but in cases
    # like this, I feel it reads much better with #(), or even #[].
  end

  def sort_line_items
    result = {}
    LineItem.includes(
      imprintable_variant: [:color, :size]
    )
      .where(line_itemable_id: id, line_itemable_type: 'Job')
      .where.not(imprintable_variant_id: nil).each do |line_item|
        imprintable_name = line_item.imprintable.name
        variant          = line_item.imprintable_variant
        color_name       = variant.color.name

        result[imprintable_name] ||= {}
        result[imprintable_name][color_name] ||= []
        result[imprintable_name][color_name] << line_item
      end

    result.values.each { |by_color| by_color.values.each(&:sort!) }
    result
  end

  def standard_line_items
    LineItem.non_imprintable.where(line_itemable_id: id,
                                   line_itemable_type: 'Job')
  end

  def total_quantity
    line_items.empty? ? 0 : line_items.map(&:quantity).reduce(0, :+)
  end

  def name_number_csv
    csv = imprints
      .with_name_number
      .map { |i| [i.name_number.number, i.name_number.name] }

    CSV.from_arrays csv, headers: %w(Number Name), write_headers: true
  end

  def name_number_imprints
    imprints.includes(:imprint_method).where('imprint_methods.name = "Name/Number"').references(:imprint_methods)
  end

  private

  def assure_name_and_description
    return unless jobbable_type == 'Order'
    if name.nil?
      new_job_name = 'New Job'
      counter = 1

      while Job.where(jobbable_id: self.jobbable_id, name: new_job_name).exists?
        counter += 1
        new_job_name = "New Job #{counter}"
      end

      self.name = new_job_name
    end

    self.description = 'Click to edit description' if self.description.nil?
    self.collapsed = true
  end

  def check_for_line_items
    return if jobbable_type == 'Quote'

    if LineItem.where(line_itemable_id: id, line_itemable_type: 'Job').exists?
      self.errors[:deletion_status] =
        'All line items must be manually removed before a job can be deleted'
      false
    else
      true
    end
  end

  def max_print(print_location, width_or_height)
    (
      imprintables.map(&"max_imprint_#{width_or_height}".to_sym) +
      [print_location.send("max_#{width_or_height}")]
    )
      .map(&:to_f).min
  end

  def destroy_self_if_line_items_and_imprints_are_empty
    return unless jobbable_type == 'Quote'
    return if name == Quote::MARKUPS_AND_OPTIONS_JOB_NAME
    destroy if line_items.empty? && imprints.empty?
  end
end
