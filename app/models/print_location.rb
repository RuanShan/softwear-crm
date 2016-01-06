class PrintLocation < ActiveRecord::Base
  acts_as_paranoid

  belongs_to :imprint_method
  has_many :imprints

  validates :max_height, numericality: true, presence: true
  validates :max_width, numericality: true, presence: true
  validates :name, presence: true, uniqueness: { scope: :imprint_method }

  default_scope { order(popularity: :desc) }

  def qualified_name
    "#{name} (#{imprint_method.name})"
  end

  def self.update_popularity(id)
    PrintLocation.find(id).update_popularity
  end
  def update_popularity
    self.popularity = imprints.where('updated_at > ?', 2.months.ago).size
    save!
  end
end
