class Imprint < ActiveRecord::Base
  include TrackingHelpers
  include ProductionCounterpart

  attr_reader :name_number_expected

  acts_as_paranoid

  tracked by_current_user + on_order

  belongs_to :job
  belongs_to :print_location
  belongs_to :production, class_name: 'Production::Imprint', foreign_key: :softwear_prod_id
  has_many :name_numbers
  has_one :imprint_method, through: :print_location
  has_many :ink_colors, through: :imprint_method
  has_many :artwork_request_imprints
  has_many :artwork_requests, through: :artwork_request_imprints
  has_many :proofs, -> (i) { where(job_id: i.job_id) }, through: :artwork_requests
  has_many :artworks, through: :proofs

  validates :job, presence: true
  validates :print_location, presence: true, uniqueness: { scope: :job_id }

  scope :name_number, -> { joins(:imprint_method).where(imprint_methods: { name: 'Name/Number' }) }

  def name
    "#{imprint_method.try(:name) || 'n\a'} - #{print_location.try(:name) || 'n\a'} - #{description}"
  end

  def job_and_name
    "#{job.name} - #{name}"
  end

  def count
    job.imprintable_line_items_total
  end

  def sync_with_production(sync)
    sync[:name]
    sync[description: :job_and_name]
    sync[:count]
  end

  def number_count
    counts = {}
    numbers_in_imprint = name_numbers.map{|x| x.number.split(//)}.flatten.sort{|x, y| x <=> y}
    numbers_in_imprint.uniq.map{|x| counts[x] = numbers_in_imprint.count(x) }
    counts
  end

end
