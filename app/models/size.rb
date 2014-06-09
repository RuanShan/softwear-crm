class Size < ActiveRecord::Base
  default_scope { order(:sort_order).where(:deleted_at => nil)}
  before_validation :set_sort_order
  scope :deleted, -> { unscoped.where.not(deleted_at: nil)}

  has_many :imprintable_variants

  validates :name, uniqueness: true, presence: true
  validates :sku, uniqueness: true, presence: true, length: { is: 2 }
  validates :sort_order, uniqueness: true, presence: true

  def destroyed?
    !deleted_at.nil?
  end

  def destroy
    update_attribute(:deleted_at, Time.now)
  end

  def destroy!
    update_column(:deleted_at, Time.now)
  end

  private

  def set_sort_order

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
