class ImprintMethod < ActiveRecord::Base
  acts_as_paranoid

  has_many :imprint_method_imprintables
  has_many :imprintables, through: :imprint_method_imprintables
  has_many :imprint_method_ink_colors
  has_many :ink_colors, through: :imprint_method_ink_colors
  has_many :print_locations, dependent: :destroy
  has_many :imprints, through: :print_locations
  has_many :option_types, class_name: "Pricing::OptionType"

  accepts_nested_attributes_for :print_locations, :option_types, allow_destroy: true

  validates :name, presence: true, uniqueness: true

  scope :name_number, -> { where(name_number: true) }

  def ink_color_names
    ink_colors.pluck(:name)
  end

  def ink_color_names=(new_ink_color_names)
    ids = new_ink_color_names.map do |name|
      ImprintMethodInkColor.find_or_create_by(
        imprint_method_id: id,
        ink_color_id: InkColor.find_or_create_by(name: name).id
      )
        .id
    end
    imprint_method_ink_colors.where.not(id: ids).destroy_all
  end
end
