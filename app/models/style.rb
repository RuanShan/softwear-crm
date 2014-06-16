class Style < ActiveRecord::Base
  acts_as_paranoid

  belongs_to :brand
  has_one :imprintable, dependent: :destroy

  validates :name, :uniqueness =>  { :scope => :brand_id }, presence: true
  validates :sku, presence: true, uniqueness: true, length: { is: 2 }
  validates :catalog_no, :uniqueness => { :scope => :brand_id }, presence: true
  validates :brand, presence: true

  def find_brand
    Brand.find(self.brand_id) if self.brand_id
  end
end
