class ImprintableImprintableGroup < ActiveRecord::Base
  validates :tier, presence: true, inclusion: {
    in: Imprintable::TIERS.keys,
    message: "must be one of these: #{Imprintable::TIERS.keys}"
  }
  validates :default,
            uniqueness: {
              scope: [:imprintable_group_id, :tier],
              message: 'Only one default for each tier-group pair'
            },
            if: :default

  belongs_to :imprintable_group
  belongs_to :imprintable

  def self.default
    where(default: true).first
  end
end
