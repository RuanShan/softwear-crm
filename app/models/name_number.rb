class NameNumber < ActiveRecord::Base
  belongs_to :imprint
  belongs_to :imprintable_variant
  has_one :imprintable, through: :imprintable_variant
  has_one :brand, through: :imprintable
  has_one :size, through: :imprintable_variant

  validates :imprint_id, presence: true
  validates :imprintable_variant_id, presence: true
end
