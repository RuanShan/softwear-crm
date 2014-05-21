class ShippingMethod < ActiveRecord::Base

  validates :name, uniqueness: true, presence: true
  validates :tracking_url, format: {with: URI::regexp(%w(http https)), message: 'should be in format http://www.url.com/path'}

  default_scope -> { where(deleted_at: nil) }
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
