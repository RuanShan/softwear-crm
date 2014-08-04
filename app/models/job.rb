class Job < ActiveRecord::Base
  include TrackingHelpers

  acts_as_paranoid
  tracked by_current_user + on_order

  belongs_to :order

  has_many :line_items, as: :line_itemable
  has_many :imprints
  has_many :imprintable_variants, -> {readonly}, through: :line_items
  has_many :imprintables, -> {readonly}, through: :imprintable_variants
  has_many :colors, -> {readonly}, through: :imprintable_variants

  has_and_belongs_to_many :artwork_requests

  before_destroy :check_for_line_items

  validate :assure_name_and_description, on: :create
  validates :name, uniqueness: { scope: :order_id }

  #TODO: look at this
  def sort_line_items
    result = {}
    LineItem.includes(
      imprintable_variant: [
        :color, :size
      ]
    ).where(line_itemable_id: id, line_itemable_type: 'Job').where.not(imprintable_variant_id: nil).each do |line_item|
      imprintable_name = line_item.imprintable.name
      variant = line_item.imprintable_variant
      color_name = variant.color.name

      result[imprintable_name] ||= {}
      result[imprintable_name][color_name] ||= []
      result[imprintable_name][color_name] << line_item
    end
    result.each { |k, v| v.each { |k, v| v.sort! } }
    result
  end

  def standard_line_items
    LineItem.non_imprintable.where(line_itemable_id: id, line_itemable_type: 'Job')
  end

  def imprintable_variant_count
    # TODO: inject and nested ternary
    line_items.empty? ? 0 : line_items.map{|li| li.imprintable_variant_id ? li.quantity : 0}.inject{|sum, x| sum + x }
  end

  def imprintable_info
    colors = []
    style_names = []
    style_catalog_nos = []
    sorted_line_items = self.sort_line_items

      unless sorted_line_items.empty?
        sorted_line_items.each do |_imprintable_name, by_color|
          by_color.each do |color_name, line_items|
            colors << color_name
            style_names << line_items.first.style_name
            style_catalog_nos << line_items.first.style_catalog_no
          end
        end
      end

    (colors).zip(style_names, style_catalog_nos).map{|array| array.join(' ')}.join(', ')
  end

  def total_quantity
    # TODO: inject
    line_items.empty? ? 0 : line_items.map{|li| li.quantity}.inject{|sum, x| sum + x }
  end

  def max_print_area(print_location)
    #TODO: refactor
    width = (imprintables.map{ |i| i.max_imprint_width.to_f } << print_location.max_width.to_f).min
    height = (imprintables.map{ |i| i.max_imprint_height.to_f } << print_location.max_height.to_f).min
    return width, height
  end

  searchable do
    text :name, :description
    string :name
    reference :order
  end

  private

  def assure_name_and_description
    # TODO: remove self?
    if self.name.nil?
      new_job_name = 'New Job'
      counter = 1

      while Job.where(order_id: self.order_id).where(name: new_job_name).exists?
        counter += 1
        new_job_name = "New Job #{counter}"
      end

      self.name = new_job_name
    end

    self.description = 'Click to edit description' if self.description.nil?
    self.collapsed = true
  end

  def check_for_line_items
    if LineItem.where(line_itemable_id: id, line_itemable_type: 'Job').exists?
      self.errors[:deletion_status] = 'All line items must be manually removed before a job can be deleted'
      false
    else
      true
    end
  end
end
