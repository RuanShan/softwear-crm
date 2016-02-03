class Proof < ActiveRecord::Base
  include TrackingHelpers

  scope :pending, -> { where('state != ?', 'customer_approved') }

  acts_as_paranoid

  searchable do

  end

  tracked by_current_user + on_order

  belongs_to :order
  belongs_to :job
  has_many :artwork_proofs
  has_many :artworks, through: :artwork_proofs
  has_many :artwork_requests, through: :artworks
  has_many :mockups, as: :assetable, class_name: Asset, dependent: :destroy

  accepts_nested_attributes_for :mockups, allow_destroy: true

  validates :approve_by, presence: true
  validates :artworks, presence: true

  state_machine :state, initial: :not_ready do

    ########################
    # Callbacks
    #########################
    after_transition on: :ready do |proof|
      proof.order.proofs_ready unless proof.order.proofs.map{|p| p.state }.include?('not_ready')
    end

    after_transition on: :manager_approved do |proof|
      proof.order.proofs_manager_approved unless proof.order.proofs.map{|p| p.state }.include?('pending_manager_approval')
    end

    after_transition on: :emailed_customer do |proof|
      proof.order.emailed_customer_proofs unless proof.order.proofs.map{|p| p.state }.include?('pending_customer_submission')
    end

    after_transition on: :customer_approved do |proof|
      proof.order.proofs_customer_approved unless proof.order.proofs.map{|p| p.state }.include?('pending_customer_approval')
    end

    after_transition on: :customer_rejected do |proof|
      proof.order.proofs_customer_rejected
    end

    after_transition on: :manager_rejected do |proof|
      proof.order.proofs_manager_rejected
    end

    ############################
    # Transitions
    ############################
    event :ready do
      transition :not_ready => :pending_manager_approval
    end

    event :manager_approved do
      transition :pending_manager_approval => :pending_customer_submission
    end

    event :manager_rejected do
      transition any => :manager_rejected
    end

    event :emailed_customer do
      transition :pending_customer_submission => :pending_customer_approval
    end

    event :customer_approved do
      transition :pending_customer_approval => :customer_approved
      transition :pending_customer_submission => :customer_approved
    end

    event :customer_rejected do
      transition any => :customer_rejected
    end
  end

  def mockup_paths
    mockups.map do |mockup|
      [
        mockup.file.url(:thumb),
        mockup.file.url
      ]
    end
  end

  def artwork_paths
    artworks.map do |artwork|
      [
        artwork.preview.try(:file).try(:url, :thumb),
        artwork.path
      ]
    end
  end
end
