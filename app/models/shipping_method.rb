class ShippingMethod < ActiveRecord::Base
  include PublicActivity::Model
  tracked

  validates :name, uniqueness: true, presence: true
  validates :tracking_url, format: {with: URI::regexp(%w(http https)), message: 'should be in format http://www.url.com/path'}

  default_scope -> { where(deleted_at: nil) }
  scope :deleted, -> { unscoped.where.not(deleted_at: nil)}

  def destroyed?
    !deleted_at.nil?
  end

  def destroy
    update_columns(deleted_at: Time.now, updated_at: Time.now)
  end

  def destroy!
    update_column(:deleted_at, Time.now)
  end

end
