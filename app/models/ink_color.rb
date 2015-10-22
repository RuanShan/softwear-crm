class InkColor < ActiveRecord::Base
  acts_as_paranoid

  has_many :imprint_method_ink_colors
  has_many :imprint_methods, through: :imprint_method_ink_colors
  has_many :artwork_request_ink_colors
  has_many :artwork_requests, through: :artwork_request_ink_colors

  validates :name, presence: true, uniqueness: true

  def self.compatible_with(imprint_methods)
    return [] if imprint_methods.blank?

    if imprint_methods.is_a?(ActiveRecord::Relation)
      imprint_method_ids = imprint_methods.pluck(:id)
    else
      imprint_method_ids = imprint_methods.map(&:id)
    end

    ink_color_ids = InkColor
      .joins(:imprint_methods)
      .where(imprint_methods: { id: imprint_method_ids })
      .pluck(:id)

    imprint_methods.each do |imprint_method|
      ink_color_ids &= imprint_method.ink_color_ids
    end

    InkColor.where(id: ink_color_ids)
  end

  def display_name
    custom? ? "Custom (#{name})" : name
  end
end
