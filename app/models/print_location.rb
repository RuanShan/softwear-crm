class PrintLocation < ActiveRecord::Base
  include Popularity

  acts_as_paranoid
  popularity_rated_from :imprints

  belongs_to :imprint_method
  has_many :imprints

  validates :max_height, numericality: true, presence: true
  validates :max_width, numericality: true, presence: true
  validates :name, presence: true, uniqueness: { scope: :imprint_method }

  def qualified_name
    "#{name} (#{imprint_method.name})"
  end

  def name_and_popularity
    "#{name} (*#{popularity})"
  end
end
