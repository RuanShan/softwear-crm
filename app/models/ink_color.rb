class InkColor < ActiveRecord::Base
  acts_as_paranoid

=begin
  # BEFORE MIGRATION
  belongs_to :imprint_method
  has_many :artwork_request_ink_colors
  has_many :artwork_requests, through: :artwork_request_ink_colors
=end

  # AFTER MIGRATION
  has_many :imprint_method_ink_colors
  has_many :imprint_methods, through: :imprint_method_ink_colors
  has_many :artwork_request_ink_colors
  has_many :artwork_requests, through: :artwork_request_ink_colors

  validates :name, presence: true, uniqueness: true

  def self.compatible_with(imprint_methods)
    return [] if imprint_methods.blank?

    ink_color_counts = {}
    imprint_method_count = imprint_methods.size
    unless imprint_methods.is_a?(ActiveRecord::Relation)
      imprint_methods = ImprintMethod.where(id: imprint_methods.compact.map(&:id))
    end

    potential_ink_color_ids = InkColor
      .joins(:imprint_methods)
      .where(imprint_methods: { id: imprint_methods.pluck(:id) })

    potential_ink_color_ids.each do |ink_color_id|
      ink_color_counts[ink_color_id] =
        imprint_methods.joins(:ink_colors).where(ink_colors: { id: ink_color_id }).size
    end

    ink_color_ids = ink_color_counts.keys
      .select { |ink_color_id| ink_color_counts[ink_color_id] == imprint_method_count }

    InkColor.where(id: ink_color_ids)
  end
end
