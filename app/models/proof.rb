class Proof < ActiveRecord::Base
  include TrackingHelpers

  acts_as_paranoid

  tracked by_current_user + on_order

  VALID_PROOF_STATUSES = ['Pending', 'Emailed Customer', 'Approved', 'Rejected']

  belongs_to :order
  has_many :mockups, as: :assetable, class_name: Asset, dependent: :destroy
  has_and_belongs_to_many :artworks
  accepts_nested_attributes_for :mockups, allow_destroy: true

  validates :status, presence: true
  validates :approve_by, presence: true
  validates :artworks, presence: true

  private

end