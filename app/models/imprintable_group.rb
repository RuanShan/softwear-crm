class ImprintableGroup < ActiveRecord::Base
  validates :name, uniqueness: true, presence: true
  has_many :imprintable_imprintable_groups
  has_many :imprintables, through: :imprintable_imprintable_groups

  def default_imprintable_for_tier(tier)
    imprintable_imprintable_groups
      .where(tier: tier, default: true)
      .first
      .try(:imprintable)
  end
end
