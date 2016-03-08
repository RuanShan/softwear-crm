class Size < ActiveRecord::Base
  include Retailable

  UPCHARGE_GROUPS = {
    base_price:    'Base',
    xxl_price:     '2XL',
    xxxl_price:    '3XL',
    xxxxl_price:   '4XL',
    xxxxxl_price:  '5XL',
    xxxxxxl_price: '6XL'
  }

  acts_as_paranoid

  default_scope { order(:sort_order) }

  before_validation :set_sort_order

  has_many :imprintable_variants, dependent: :destroy, inverse_of: :size

  validates :name, presence: true, uniqueness: true
  validates :sku, length: { is: 2 }, if: :is_retail?
  validates :sort_order, presence: true, uniqueness: true
  validates :upcharge_group, inclusion: { in: UPCHARGE_GROUPS.keys.map(&:to_s) }, if: :upcharge_group
  
  private

  def set_sort_order
    if self.sort_order.nil?
      last_sort_order = if Size.order(:sort_order).last
                          Size.order(:sort_order).last.sort_order
                        else
                          0
                        end
      self.sort_order = 1 + (last_sort_order.nil? ? 0 : last_sort_order)
    end
  end
end
