class Job < ActiveRecord::Base
  belongs_to :order

  has_many :line_items
  has_many :imprints
  has_many :imprintable_variants, -> {readonly}, through: :line_items
  has_many :imprintables, -> {readonly}, through: :imprintable_variants
  has_many :colors, -> {readonly}, through: :imprintable_variants
  has_many :styles, -> {readonly}, through: :imprintables

  has_and_belongs_to_many :artwork_requests

  before_destroy :check_for_line_items

  validate :assure_name_and_description, on: :create
  validates :name, uniqueness: { scope: :order_id }


  acts_as_paranoid
  
  def sort_line_items
    result = {}
    LineItem.includes(
      imprintable_variant: [
        { imprintable: :style }, :color, :size
      ]
    ).where(job_id: id).where.not(imprintable_variant_id: nil).each do |line_item|
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
    LineItem.non_imprintable.where job_id: id
  end

  def imprintable_variant_count
    line_items.empty? ? 0 : line_items.map{|li| li.imprintable_variant_id ? li.quantity : 0}.inject{|sum, x| sum + x }
  end

  def imprintable_color_names
    colors.map{|c| c.name}
  end

  def imprintable_style_names
    styles.map{|s| s.name}
  end
  def imprintable_style_catalog_nos
    styles.map{|s| s.catalog_no}
  end

  def imprintable_info
    (imprintable_color_names).zip(imprintable_style_names, imprintable_style_catalog_nos).map{|array| array.join(' ')}.join(', ')
  end

  def total_quantity
    line_items.empty? ? 0 : line_items.map{|li| li.quantity}.inject{|sum, x| sum + x }
  end


  searchable do
    text :name, :description
    string :name
    reference :order
  end

private
  def assure_name_and_description
    if self.name.nil?
      new_job_name = 'New Job'
      counter = 1
      while Job.where(order_id: self.order_id).where(name: new_job_name).exists?
        counter += 1
        new_job_name = "New Job #{counter}"
      end
      self.name = new_job_name
    end
    self.description = "Click to edit description" if self.description.nil?
    self.collapsed = true
  end

  def check_for_line_items
    if LineItem.where(job_id: id).exists?
      self.errors[:deletion_status] = 'All line items must be manually removed before a job can be deleted'
      false
    else
      true
    end
  end
end
