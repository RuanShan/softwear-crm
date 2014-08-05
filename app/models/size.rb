class Size < ActiveRecord::Base
  include Retailable

  acts_as_paranoid

  default_scope { order(:sort_order) }

  before_validation :set_sort_order

  has_many :imprintable_variants, dependent: :destroy

  validates :name, presence: true, uniqueness: true
  validates :sku, length: { is: 2 }, if: :is_retail?
  validates :sort_order, presence: true, uniqueness: true

  private

  def set_sort_order
    # TODO: ternary and refactor
    if self.sort_order.nil?
      if Size.order(:sort_order).last
        last_sort_order = Size.order(:sort_order).last.sort_order
      else
        last_sort_order = 0
      end
      self.sort_order = 1 + (last_sort_order.nil? ? 0 : last_sort_order)
    end
  end
end
