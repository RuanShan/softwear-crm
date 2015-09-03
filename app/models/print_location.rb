class PrintLocation < ActiveRecord::Base
  acts_as_paranoid

  belongs_to :imprint_method
  belongs_to :platen_hoop
  has_many :imprints

  validates :max_height, numericality: true, presence: true
  validates :max_width, numericality: true, presence: true
  validates :name, presence: true, uniqueness: { scope: :imprint_method }

  default_scope { order(:name) }

  def qualified_name
    "#{name} (#{imprint_method.name})"
  end
end
