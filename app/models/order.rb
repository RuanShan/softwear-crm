class Order < ActiveRecord::Base
  validates_presence_of :email, :firstname, :lastname, :name, :terms, :delivery_method
  validates :email, format: { with: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i }
  validates :phone_number, format: { with: /\d{3}-\d{3}-\d{4}/, message: "is incorrectly formatted, use 734-555-1212" }
  validates_inclusion_of(:sales_status, 
      in: [:pending, :terms_set, :terms_set_and_met, :paid], 
      message: 'is not a valid sales status')
  validates_inclusion_of(:delivery_method,
      in: [:pick_up_in_ann_arbor, :pick_up_in_ypsilanti, 
           :ship_to_one, :ship_to_multiple])


  validates_presence_of :tax_id_number, if: :tax_exempt?
  validates_presence_of :redo_reason, if: :needs_redo?

  # non-deletable stuff
  default_scope -> { where(deleted_at: nil) }
  scope :deleted, -> { unscoped.where.not(deleted_at: nil) }

  def destroyed?
    !deleted_at.nil?
  end

  def destroy
    update_attribute(:deleted_at, Time.now)
  end

  def destroy!
    update_column(:deleted_at, Time.now)
  end

  def revive
    update_attribute(:deleted_at, nil) if !deleted_at.nil?
  end
end