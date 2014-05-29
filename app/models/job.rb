class Job < ActiveRecord::Base
  belongs_to :order

  validates_presence_of :name
  validates :name, uniqueness: { scope: :order_id }

  # non-deletable stuff
  default_scope -> { where(deleted_at: nil) }
  scope :deleted, -> { unscoped.where.not(deleted_at: nil) }

  def destroyed?
    !deleted_at.nil?
  end

  def destroy
  	update_attributes({
  		name: "#{name} #{Time.now}",
  		deleted_at: Time.now
  	})
  end

  def destroy!
    update_columns({
  		name: "#{name} #{Time.now}",
  		deleted_at: Time.now
  	})
  end
end
