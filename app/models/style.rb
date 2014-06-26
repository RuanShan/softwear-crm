class Style < ActiveRecord::Base
  acts_as_paranoid

  include Retailable

  belongs_to :brand
  has_one :imprintable, dependent: :destroy

  validates :name, :uniqueness =>  { :scope => :brand_id }, presence: true
  validates :sku, length: { is: 2 }, if: :is_retail?
  validates :catalog_no, :uniqueness => { :scope => :brand_id }, presence: true
  validates :brand, presence: true

  def find_brand
    Brand.find(self.brand_id) if self.brand_id
  end

  default_scope { eager_load(:brand).joins(:brand).order('brands.name, styles.catalog_no').readonly(false) }

end
