class Style < ActiveRecord::Base
  default_scope -> { where(deleted_at: nil) }
  scope :deleted, -> { unscoped.where.not(deleted_at: nil)}

  belongs_to :brand

  has_one :imprintable

  validates :name, :uniqueness =>  { :scope => :brand_id }, presence: true
  validates :sku, presence: true, uniqueness: true, length: { is: 2}
  validates :catalog_no, :uniqueness => { :scope => :brand_id }, presence: true
  validates :brand, presence: true

  def find_brand
    if self.brand_id
      Brand.find(self.brand_id)
    end
  end

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
