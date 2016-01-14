class FbaSku < ActiveRecord::Base
  belongs_to :fba_product
  belongs_to :imprintable_variant
  belongs_to :fba_job_template

  validates :fba_product, :imprintable_variant, :fba_job_template, presence: true
  validates :sku, presence: true, uniqueness: true
end
