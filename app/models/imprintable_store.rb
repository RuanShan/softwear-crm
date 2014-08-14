class ImprintableStore < ActiveRecord::Base
  acts_as_paranoid

  belongs_to :imprintable
  belongs_to :store

  validates :imprintable_id, uniqueness: { scope: :store_id }
end
