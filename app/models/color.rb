class Color < ActiveRecord::Base
  has_many :imprintable_variants
  validates :name, uniqueness: true, presence: true
  validates :sku, uniqueness: true, presence: true

  attr_accessor :valid_imprintable_variants_count

  default_scope -> { where(deleted_at: nil) }
  scope :deleted, -> { unscoped.where.not(deleted_at: nil) }

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
