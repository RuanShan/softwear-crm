class NameNumber < ActiveRecord::Base
  belongs_to :imprint
  belongs_to :imprintable_variant
  has_one :job, through: :imprint

  validates :imprint_id, presence: true
  validates :imprintable_variant_id, presence: true

  validate :doesnt_exceed_line_item_quantity

  def doesnt_exceed_line_item_quantity
    return if job.nil?

    mismatch = job
      .mismatched_name_number_quantities(:<, add_name_numbers: self)
      .find { |m| m.variant.id == imprintable_variant_id }

    if mismatch.present?
      errors.add(
        :job,
        "lists #{mismatch.line_item_quantity} line items, trying to add "\
        "a #{mismatch.name_number_count.ordinalize} name/number"
      )
    end
  end
end
