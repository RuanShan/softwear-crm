class ImprintablePhoto < ActiveRecord::Base
  belongs_to :color
  has_one :asset, as: :assetable
  belongs_to :imprintable

  validates :color, :asset, :imprintable, presence: true

  after_save :unset_previous_default

  private

  def unset_previous_default
    if default?
      ImprintablePhoto
        .where.not(id: id)
        .where(imprintable_id: imprintable_id, default: true)
        .update_all(default: false)
    end
  end
end
