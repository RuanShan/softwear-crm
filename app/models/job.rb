class Job < ActiveRecord::Base
  belongs_to :order

  has_many :line_items

  validates_presence_of :name
  validates :name, uniqueness: { scope: :order_id }

  # non-deletable stuff
  inject NonDeletable, track_methods: true

  def destroy
    original_destroy
    update_attribute :name, "#{name} #{Time.now.to_s}"
  end

  def destroy!
    original_destroy!
    update_column update_attribute :name, "#{name} #{Time.now.to_s}"
  end

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
end
