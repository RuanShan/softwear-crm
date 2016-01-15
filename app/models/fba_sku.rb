class FbaSku < ActiveRecord::Base
  belongs_to :fba_product
  belongs_to :imprintable_variant
  belongs_to :fba_job_template
  has_one :imprintable, through: :imprintable_variant
  has_one :brand, through: :imprintable
  has_one :color, through: :imprintable_variant
  has_one :size, through: :imprintable_variant

  validates :imprintable_variant, :fba_job_template, presence: true
  validates :sku, presence: true, uniqueness: true
end
