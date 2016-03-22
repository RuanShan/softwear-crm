class Cost < ActiveRecord::Base
  include Softwear::Auth::BelongsToUser

  self.inheritance_column = nil

  SELECTABLE_TYPES = ['Salesperson', 'Artist']

  belongs_to_user_called :owner
  belongs_to :costable, polymorphic: true

  before_save :set_type_and_description, if: :line_item?

  def type=(t)
    # Allow array input from orders/_cost_fields select2
    if t.is_a?(Array)
      t = t.reject(&:blank?).last
    end

    # Don't allow silly capitalization mistakes
    if t.downcase == 'salesperson'
      t = 'Salesperson'
    elsif t.downcase == 'artist'
      t = 'Artist'
    end

    super(t)
  end

  def line_item?
    costable_type == 'LineItem'
  end

  def set_type_and_description
    return if costable.nil?

    if costable.imprintable?
      self.type = "Imprintable"
      self.description = "Cost of imprintables"
    else
      self.type = "Line Item"
      self.description = "Unit cost of #{costable.name}"
    end
  end
end
