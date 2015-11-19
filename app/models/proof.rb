class Proof < ActiveRecord::Base
  include TrackingHelpers

  scope :pending, -> { where('status != ?', 'Approved') }

  acts_as_paranoid

  searchable do 
    
  end

  tracked by_current_user + on_order

  VALID_PROOF_STATUSES = [
      'Pending',
      'Emailed Customer',
      'Approved',
      'Rejected'
  ]

  belongs_to :order
  belongs_to :job
  has_many :artwork_proofs
  has_many :artworks, through: :artwork_proofs
  has_many :artwork_requests, through: :artworks
  has_many :mockups, as: :assetable, class_name: Asset, dependent: :destroy

  accepts_nested_attributes_for :mockups, allow_destroy: true

  validates :approve_by, presence: true
  validates :artworks, presence: true
  validates :status, presence: true

  after_save :update_order_proof_state

  def mockup_paths
    mockups.map do |mockup|
      [
        mockup.file.url(:thumb),
        mockup.file.url
      ]
    end
  end

  def update_order_proof_state
    Sunspot.index order
  end

end
