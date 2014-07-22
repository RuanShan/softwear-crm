class Quote < ActiveRecord::Base
  acts_as_paranoid

  has_many :line_items, as: :line_itemable
  belongs_to :salesperson, class_name: User
  belongs_to :store

  accepts_nested_attributes_for :line_items, allow_destroy: true

  validates :email, presence: true, format: { with: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i }
  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :valid_until_date, presence: true
  validates :estimated_delivery_date, presence: true
  validates :salesperson_id, presence: true
  validates :store_id, presence: true
  validate :has_line_items?

  def has_line_items?
    errors.add(:base, 'Quote must have at least one line item') if self.line_items.blank?
  end

  def full_name
    "#{first_name} #{last_name}"
  end

  def line_items_subtotal
    total = 0
    self.line_items.each do |li|
      total += li.price
    end
    total
  end

  def line_items_total_tax
    total = 0
    self.line_items.each do |li|
      if li.taxable?
        # hard-coded 6% tax is probably subject to change
        total += li.price*1.06
      end
    end
    total
  end

  def line_items_total_with_tax
    total = 0
    self.line_items.each do |li|
      if li.taxable?
      # hard-coded 6% tax is probably subject to change
        total += li.price*1.06
      else
        total += li.price
      end
    end
    total
  end

  def formatted_phone_number
    if phone_number
      area_code = phone_number[0, 3]
      middle_three = phone_number[3, 3]
      last_four = phone_number[6, 4]
      "(#{area_code}) #{middle_three}-#{last_four}"
    end
  end

  def sort_line_items
    result = {}
    LineItem.includes(
        imprintable_variant: [
            { imprintable: :style }, :color, :size
        ]
    ).where(line_itemable_id: id, line_itemable_type: 'Quote').where.not(imprintable_variant_id: nil).each do |line_item|
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
    LineItem.non_imprintable.where(line_itemable_id: id, line_itemable_type: 'Quote')
  end
end
