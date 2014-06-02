class LineItem < ActiveRecord::Base
  belongs_to :job
  belongs_to :imprintable_variant

  validates_presence_of :name, unless: :imprintable?
  validates_presence_of :description, unless: :imprintable?

  inject NonDeletable

  def price; unit_price * quantity; end

  def imprintable?
    imprintable_variant_id != nil
  end

  def description
    if imprintable?
      imprintable_variant.imprintable.description
    else
      read_attribute :description
    end
  end
end