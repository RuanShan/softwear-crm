class ImprintMethodImprintable < ActiveRecord::Base
  acts_as_paranoid

  belongs_to :imprint_method
  belongs_to :imprintable

  validates :imprint_method_id, uniqueness: { scope: :imprintable_id }
end
