class ImprintMethod < ActiveRecord::Base
  acts_as_paranoid

  has_many :ink_colors, dependent: :destroy
  has_many :print_locations, dependent: :destroy
  # TODO: habtm and refactor join_table?
  has_and_belongs_to_many :imprintables, association_foreign_key: 'imprint_method_id',
                                         join_table: 'imprint_methods_imprintables'
  accepts_nested_attributes_for :ink_colors, allow_destroy: true
  accepts_nested_attributes_for :print_locations, allow_destroy: true

  validates :name, presence: true, uniqueness: true
end
