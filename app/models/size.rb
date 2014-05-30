class Size < ActiveRecord::Base
  validates :name, uniqueness: true, presence: true
  validates :sku, uniqueness: true, presence: true
  validates :sequence, presence: true

  default_scope { order(:sequence)}
  before_validation :set_sequence

  inject NonDeletable

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
