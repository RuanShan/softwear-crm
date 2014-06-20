class Job < ActiveRecord::Base
  belongs_to :order

  has_many :line_items
  has_many :imprints

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

  searchable do
    text :name, :description

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
