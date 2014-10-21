class NameNumber < ActiveRecord::Base
  belongs_to :imprint
  belongs_to :imprintable_variant

  validates :imprint_id, presence: true
  validates :imprintable_variant_id, presence: true
end
