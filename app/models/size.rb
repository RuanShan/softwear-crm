class Size < ActiveRecord::Base
  validates :name, uniqueness: true, presence: true
  validates :sku, uniqueness: true, presence: true
  validates :sequence, presence: true

  default_scope { order(:sequence)}
  before_validation :set_sequence

  default_scope { where(:deleted_at => nil)}
  scope :deleted, -> { unscoped.where.not(deleted_at: nil)}

  def destroyed?
    !deleted_at.nil?
  end

  def destroy
    update_attribute(:deleted_at, Time.now)
  end

  def destroy!
    update_column(:deleted_at, Time.now)
  end

  private

  def set_sequence
    if self.sequence.nil?
      if Size.order(:sequence).last
        last_sequence = Size.order(:sequence).last.sequence
      else
        last_sequence = 0
      end
      self.sequence = 1 + (last_sequence.nil? ? 0 : last_sequence)
    end
  end
end
