class Style < ActiveRecord::Base
  validates :name, uniqueness: true, presence: true
  validates :sku, uniqueness: true, presence: true
  validates :catalog_no, presence: true

  inject NonDeletable
end
