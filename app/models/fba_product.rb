class FbaProduct < ActiveRecord::Base
  has_many :fba_skus, dependent: :destroy

  accepts_nested_attributes_for :fba_skus, allow_destroy: true

  validates :name, :sku, presence: true, uniqueness: true

  searchable do
    text :name, :sku, :fba_sku_skus
  end

  def fba_sku_skus
    fba_skus.pluck(:sku)
  end
end
