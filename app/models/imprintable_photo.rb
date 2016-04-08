class ImprintablePhoto < ActiveRecord::Base
  belongs_to :color
  has_one :asset, as: :assetable
  belongs_to :imprintable

  validates :color, :asset, :imprintable, presence: true
  
  before_validation :is_allowed?
  after_save :unset_previous_default

  scope :default, -> { where(default: true).first || first }

  accepts_nested_attributes_for :asset, allow_destroy: true

  def asset_attributes=(attrs)
    return if attrs[:file].blank?
    attrs[:description] = "Imprintable #{color.try(:name)} #{imprintable.try(:common_name)} photo"
    super
  end

  private

  def is_allowed?
    asset.allowed_content_type = "^image/(ai|pdf|psd|png|gif|jpeg|jpg)" if asset
  end

  def unset_previous_default
    if default?
      ImprintablePhoto
        .where.not(id: id)
        .where(imprintable_id: imprintable_id, default: true)
        .update_all(default: false)
    end
  end
end
