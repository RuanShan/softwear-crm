class ImprintableGroup < ActiveRecord::Base
  validates :name, uniqueness: true, presence: true
  has_many :imprintable_imprintable_groups
  has_many :imprintables, through: :imprintable_imprintable_groups
end
