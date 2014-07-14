class LineItem < ActiveRecord::Base
  include TrackingHelpers

  belongs_to :job
  belongs_to :imprintable_variant
  has_one :order, through: :job

  validates_presence_of :unit_price
  validates_presence_of :quantity
  validates_presence_of :name, unless: :imprintable?
  validates_presence_of :description, unless: :imprintable?
  validate :imprintable_variant_exists, if: :imprintable?
  validates :imprintable_variant_id, uniqueness: { scope: :job_id }, if: :imprintable?

  acts_as_paranoid
  tracked skip_defaults: true
  ### TODO manually call create_activity from the controller
  # or somehow allow the default activity calls to be disabled
  # (without global disable) (unless that doesn't stop you from 
  # sending custom activities)
  # 
  # The idea is to make mass-create/update/destroys from the 
  # imprintable line items to not cause activity spam.

  scope :non_imprintable, -> { where imprintable_variant_id: nil }
  scope :imprintable, -> { where.not imprintable_variant_id: nil }

  searchable do
    text :name, :description
    boolean(:is_imprintable) { imprintable? }
  end

  def price
    if unit_price && quantity
      unit_price * quantity
    else
      'NAN'
    end
  end

  def imprintable?
    imprintable_variant_id != nil
  end

  def imprintable
    imprintable_variant.imprintable
  end

  def style
    imprintable_variant.imprintable.style
  end

  [:name, :description].each do |method|
    define_method(method) do
      if imprintable?
        imprintable_variant.send method
      else
        read_attribute method
      end
    end
  end

  def size_display
    imprintable_variant.size.display_value
  end

  def <=>(other)
    return 0 if other == self
    if imprintable?
      unless other.imprintable?
        return -1
      end
      self.imprintable_variant.size.sort_order <=> other.imprintable_variant.size.sort_order
    else
      if other.imprintable?
        return +1
      end
      self.name <=> other.name
    end
  end

private
  def imprintable_variant_exists
    if ImprintableVariant.where(id: imprintable_variant_id).count < 1
      errors.add :imprintable_variant, "does not exist"
    end
  end
end
