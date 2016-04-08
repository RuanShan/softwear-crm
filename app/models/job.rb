class Job < ActiveRecord::Base
  include TrackingHelpers
  include ProductionCounterpart
  include Softwear::Lib::Enqueue

  acts_as_paranoid

  searchable do
    text :name, :description
    string :name
    reference :jobbable
    integer :id
  end

  tracked by_current_user + on_order

  default_scope { order(sort_order: :asc) }

  before_destroy :check_for_line_items
  after_update :destroy_self_if_line_items_and_imprints_are_empty
  after_create :create_default_imprint, if: :fba?
  enqueue :create_production_job, queue: 'api'
  after_update :enqueue_create_production_job, if: :needs_production_job?

  belongs_to :jobbable, polymorphic: true
  belongs_to :fba_job_template
  has_many :fba_imprint_templates, through: :fba_job_template
  has_many :fba_artworks, through: :fba_imprint_templates, source: :artwork
  has_many :artwork_requests, through: :imprints
  has_many :imprints, dependent: :destroy, inverse_of: :job
  has_many :line_items, dependent: :destroy, inverse_of: :job
  has_many :shipments, as: :shippable
  has_many :proofs
  has_many :discounts, as: :discountable
  has_many :print_locations, through: :imprints
  has_many :imprint_methods, through: :print_locations
  has_many :name_numbers, through: :imprints

  has_many :imprintable_line_items, -> { where imprintable_object_type: 'ImprintableVariant' }, class_name: 'LineItem'
  has_many :standard_line_items, -> { where imprintable_object_type: nil }, class_name: 'LineItem'

  accepts_nested_attributes_for :imprintable_line_items, :standard_line_items, :line_items, :imprints, :shipments, allow_destroy: true

  Imprintable::TIERS.each do |tier_num, tier|
    tier_line_items = "#{tier.underscore}_line_items".to_sym

    has_many tier_line_items, -> { where tier: tier_num }, class_name: 'LineItem'
    accepts_nested_attributes_for tier_line_items, allow_destroy: true
  end

  validate :assure_name_and_description, on: :create
  validates :name, uniqueness: { scope: [:jobbable_id] }, if: ->(j) { j.jobbable_type == 'Order' && j.jobbable_id }

  def mismatched_name_number_quantities(matcher = :>, options = {})
    mismatch = Struct.new(:variant, :line_item_quantity, :name_number_count)
    mismatched = []

    line_items = imprintable_line_items.to_a
    add_line_items = Array(options[:add_line_items]).compact

    unless add_line_items.empty?
      add_line_item_ids = add_line_items.map(&:id)
      line_items.reject! { |li| add_line_item_ids.include?(li.id) }
      line_items += add_line_items
    end

    line_items.each do |line|
      quantity = line.quantity
      name_numbers = NameNumber.where(imprintable_variant_id: line.imprintable_object_id)
      name_numbers += Array(options[:add_name_numbers])
        .compact
        .select { |n| n.imprintable_variant_id == line.imprintable_object_id }
    
      if quantity.send(matcher, name_numbers.size)
        mismatched << mismatch.new(
          line.imprintable_object,
          line.quantity,
          name_numbers.size
        )
      end
    end

    mismatched
  end

  def id_and_name
    "##{id} #{name}"
  end

  def all_shipments
    shipments
  end

  def needs_production_job?
    order_in_production? && !production?
  end

  def order_in_production?
    order.try(:production?)
  end

  def imprintable_line_items_total
    line_items.where.not(imprintable_object_id: nil).sum(:quantity)
  end

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

  def fba?
    jobbable_type == 'Order' && jobbable.fba?
  end

  def name_in_production
    "#{name} CRM##{id}"
  end

  def production_attributes
    {
      name: name_in_production,
      softwear_crm_id: id,
      imprints_attributes: production_imprints_attributes,
      imprintable_train_attributes: imprintable_train_attributes
    }
      .delete_if { |_,v| v.nil? }
  end

  def production_imprints_attributes
    return if imprintable_line_items_total == 0 && !imprints.any?(&:equipment_sanitizing?)

    attrs = {}

    imprints.each_with_index do |imprint, index|
      next if imprint.no_imprint?

      attrs[index] = {
        softwear_crm_id: imprint.id,
        name:            imprint.name,
        description:     imprint.job_and_name,
        count:           imprint.equipment_sanitizing? ? 1 : imprintable_line_items_total,
        type:            imprint.production_type
      }
        .delete_if { |_,v| v.nil? }
    end

    attrs
  end

  def imprintable_train_attributes
    # NOTE make sure the permitted params in Production match up with this
    if line_items.imprintable.any?
      { state: 'ready_to_order' }
    else
      nil
    end
  end

  # TODO these are deprecated for ArtworkRequest#create_trains
  def self.create_trains_from_artwork_request(job_id, artwork_request_id)
    Job.find(job_id).create_trains_from_artwork_request(ArtworkRequest.find(artwork_request_id))
  end
  def create_trains_from_artwork_request(artwork_request)
    return unless production?

    imprint_method_names = imprint_methods.pluck(:name)
    failed_imprint_methods = {}

    digital_print_count = imprint_method_names.select { |im| /Digital\s+Print/ =~ im }.size
    digital_print_count.times do
      unless Production::Ar3Train.create(
        order_id: order.softwear_prod_id,
        crm_artwork_request_id: artwork_request.id
      ).try(:persisted?)

        failed_imprint_methods['Digital Print'] = true
      end
    end

    screen_print_count = imprint_method_names.select { |im| /Screen\s+Print/ =~ im }.size
    screen_print_count.times do
      unless Production::ScreenTrain.create(
        order_id: order.softwear_prod_id,
        crm_artwork_request_id: artwork_request.id
      ).try(:persisted?)

        failed_imprint_methods['Screen Print'] = true
      end
    end

    embroidery_count = imprint_method_names.select { |im| im.include?('Embroidery') }.size
    embroidery_count.times do
      unless Production::DigitizationTrain.create(
        order_id: order.softwear_prod_id,
        crm_artwork_request_id: artwork_request.id
      ).try(:persisted?)

        failed_imprint_methods['Embroidery'] = true
      end
    end

    unless failed_imprint_methods.empty?
      order.issue_warning(
        'Job#create_trains_from_artwork_request',
        "Failed to send trains to production for the following imprint methods: "\
        "#{failed_imprint_methods.keys.join(', ')}"
      )
    end
  end

  def sync_with_production(sync)
    sync[name: :name_in_production]
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
          line_item.job = self
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

  def imprintable_variants
    ImprintableVariant.where(
      id: line_items.where(imprintable_object_type: 'ImprintableVariant')
                    .pluck(:imprintable_object_id)
    )
  end

  def imprintables_for_order
    iv_ids = ImprintableVariant.where(
      id: line_items.where(imprintable_object_type: 'ImprintableVariant')
                    .pluck(:imprintable_object_id)
    )

    Imprintable.joins(:imprintable_variants)
        .where(imprintable_variants: {id: iv_ids })
        .uniq
  end

  def imprintables
    Imprintable.where(
      id: line_items.where(imprintable_object_type: 'Imprintable')
                    .pluck(:imprintable_object_id)
    )
  end

  def colors
    Color
      .joins(:imprintable_variants)
      .where(imprintable_variants: { id: imprintable_variants.pluck(:id) })
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
      .map { |li| li.imprintable_variant? ? li.quantity : 0 }
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

  def sort_line_items(order_instance = nil)
    result = {}

    LineItem
      .where(job_id: id)
      .where.not(imprintable_object_id: nil).each do |line_item|
        if line_item.imprintable_variant.nil?
          (order_instance || order).bad_variant_ids << line_item.imprintable_object_id
          line_item.destroy
          next
        end

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
    LineItem.non_imprintable.where(job_id: id)
  end

  def total_quantity
    line_items.empty? ? 0 : line_items.map(&:quantity).reduce(0, :+)
  end

  def total_price
    line_items.map(&:total_price).map(&:to_f).reduce(0, :+)
  end

  def name_number_csv
    csv = name_and_numbers.map{|x| [ x.name ]}
    CSV.from_arrays csv
  end

  def name_number_imprints
    imprints.includes(:imprint_method).where(imprint_methods: { name_number: true }).references(:imprint_methods)
  end

  def name_and_numbers
    name_number_imprints.flat_map{|i| i.name_numbers}
    .sort{ |x, y| x.imprint_id <=> y.imprint_id }
  end

  def duplicate!
    new_job = dup

    new_job.send(:assure_name_and_description, name)
    new_job.softwear_prod_id = nil
    new_job.save!

    line_items.each do |line_item|
      new_line_item = line_item.dup
      new_line_item.quantity = 0 if new_line_item.imprintable?
      new_line_item.job = new_job
      new_line_item.save!
    end

    # Dumb way to circumvent the default screen print being added to new FBA jobs.
    new_job.imprints.destroy_all if fba?

    imprints.each do |imprint|
      new_imprint = imprint.dup
      new_imprint.job = new_job
      new_imprint.softwear_prod_id = nil
      new_imprint.save!

      if fba?
        imprint.artwork_requests.each do |ar|
          new_imprint.artwork_request_imprints.create(artwork_request_id: ar.id)
          ar.enqueue_create_imprint_group_if_needed if production?
        end
      end
    end

    new_job.reload
  end

  def create_default_imprint
    return unless imprints.empty?

    screen_print = ImprintMethod.find_by(name: 'Screen Print')
    return if screen_print.nil?
    full_chest = screen_print.print_locations.find_by(name: 'Full chest')
    return if full_chest.nil?

    Imprint.create(
      print_location_id: full_chest.id,
      job_id: id
    )
  end

  def prod_api_confirm_imprintable_train
    return if imprintables.empty?

    unless production.pre_production_trains.map(&:train_class).include?("imprintable_train")
      message = "API Job missing imprintable train CRM_ORDER(#{order.id}) CRM_JOB(#{id}) PRODUCTION(#{order.softwear_prod_id})=#{production.id}"
      logger.error message

      order.warnings << Warning.new(
        source: 'Production Configuration Report',
        message: message
      )

      Sunspot.index(order)
    end
  end

  def create_production_job
    return if order.softwear_prod_id.nil? || production?

    prod_job = Production::Job.post_raw(production_attributes.merge(order_id: order.softwear_prod_id))

    unless prod_job.persisted?
      order.issue_warning("Production API", "Job creation failed: #{prod_job.errors.full_messages}")
      return false
    end

    if prod_job.order_id.blank?
      prod_job.order_id = order.softwear_prod_id
      unless prod_job.save
        order.issue_warning(
          "Dangling Production Job",
          "Unable to assign order ID to production job. The job will be left dangling without an "\
          "order and can be properly attached by a developer. Sorry for the inconvenience."
        )
      end
    end

    update_column :softwear_prod_id, prod_job.id

    prod_job.imprints.each do |prod_imprint|
      imprints.find(prod_imprint.softwear_crm_id).update_column :softwear_prod_id, prod_imprint.id
    end

    # artwork_requests.where(state: 'manager_approved').each(&:create_trains)
    true
  end

  private

  def placeholder_name
    return unless jobbable_type == 'Order'
    jobbable.try(:fba?) ? 'Shipping Location' : 'New Job'
  end

  def assure_name_and_description(force_name = nil)
    return unless jobbable_type == 'Order'
    if name.nil? || force_name
      new_job_name = force_name || placeholder_name
      counter = 1

      while Job.where(jobbable_id: self.jobbable_id, name: new_job_name).exists?
        counter += 1
        new_job_name = "#{force_name || placeholder_name} #{counter}"
      end

      self.name = new_job_name
    end

    self.description = 'Click to edit description' if self.description.nil?
    self.collapsed = true
  end

  def check_for_line_items
    return if jobbable_type == 'Quote'

    if LineItem.where(job_id: id).exists?
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
