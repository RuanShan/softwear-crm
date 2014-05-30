class Brand < ActiveRecord::Base
  validates :name, uniqueness: true, presence: true
  validates :sku, uniqueness: true, presence: true

  inject NonDeletable
end
