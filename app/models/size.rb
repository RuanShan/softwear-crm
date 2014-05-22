class Size < ActiveRecord::Base
  validates :name, uniqueness: true, presence: true
  validates :sku, uniqueness: true, presence: true

  default_scope { order('sort_order DESC')}
  default_scope { where(:deleted_at => nil)}
  scope :deleted, -> { unscoped.where.not(deleted_at: nil)}

  def destroyed?
    !deleted_at.nil?
  end

  def destroy
    update_attribute(:deleted_at, Time.now)
  end

  def destroy!
    update_column(:deleted_at, Time.now)
  end

end
