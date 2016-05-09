class Imprint < ActiveRecord::Base
  include TrackingHelpers
  include ProductionCounterpart
  include Popularity

  attr_reader :name_number_expected

  acts_as_paranoid
  rates_popularity_of :print_location

  tracked by_current_user + on_order

  belongs_to :job, touch: true
  belongs_to :print_location
  belongs_to :production, class_name: 'Production::Imprint', foreign_key: :softwear_prod_id
  has_many :name_numbers
  has_one :imprint_method, through: :print_location
  has_many :ink_colors, through: :imprint_method
  has_many :artwork_request_imprints
  has_many :artwork_requests, through: :artwork_request_imprints
  has_many :proofs, -> (i) { where(job_id: i.job_id) }, through: :artwork_requests
  has_many :artworks, through: :proofs
  has_many :imprint_option_values, class_name: "Pricing::ImprintOptionValue"
  has_many :option_values, through: :imprint_option_values

  # validates :job, presence: true
  validates :print_location, presence: true, uniqueness: { scope: :job_id }, if: :job_id

  after_save :touch_associations
  after_save :assign_pending_selected_option_values
  after_save :update_order_artwork_state, if: :order?

  scope :name_number, -> { where(name_number: true) }

  def name
    return @name unless @name.blank? || changed?

    n = "#{imprint_method.try(:name) || 'n\a'} - #{print_location.try(:name) || 'n\a'}"

    if option_values.any?
      n << ' ('
      last_i = option_values.size - 1

      option_values.each_with_index do |option_value, i|
        n << option_value.display
        unless i == last_i
          n << ', '
        end
      end
      n << ')'
    end

    if description.present?
      n << %( "#{description}")
    end

    @name = n
  end

  def selected_option_values(force = false)
    return @pending_selected_option_values if @pending_selected_option_values && !force

    result = {}

    option_values.each do |option_value|
      result[option_value.option_type_id.to_i] = option_value
    end

    @pending_selected_option_values = result
  end

  def selected_option_values=(values)
    @pending_selected_option_values = values
  end

  def changed?
    super || (@pending_selected_option_values.present? && [@pending_selected_option_values.values - option_value_ids].length != 0)
  end

  def equipment_sanitizing?
    imprint_method.try(:name) == 'Equipment Sanitizing'
  end

  def no_imprint?
    imprint_method.try(:name) == 'No Imprint'
  end

  def name_changed?
    description_changed? || @pending_selected_option_values.present?
  end

  def job_and_name
    "#{job.name_in_production} - #{name}"
  end

  def order?
    job.jobbable_type == 'Order'
  end

  def order
    job.jobbable if job.jobbable_type == 'Order'
  end

  def count
    job.imprintable_line_items_total
  end

  def sync_with_production(sync)
    sync[:name]
    sync[description: :job_and_name]
    sync[:count]
  end

  def number_count
    counts = {}
    numbers_in_imprint = name_numbers.flat_map{|x| x.number.split(//)}.sort{|x, y| x <=> y}
    numbers_in_imprint.uniq.map{|x| counts[x] = numbers_in_imprint.count(x) }
    counts
  end

  def production_type
    case imprint_method.try(:name)
    when /Screen\s+Print/  then 'ScreenPrint'
    when /Digital\s+Print/ then 'DigitalPrint'
    when /Embroidery/      then 'EmbroideryPrint'
    when /Transfer/        then 'TransferPrint'
    when "Name/Number"     then 'TransferPrint'
    when "Equipment Sanitizing" then 'EquipmentCleaningPrint'
    else 'Print'
    end
  end

  def update_order_artwork_state
    order.check_for_imprints_requiring_artwork!
  end

  private

  def touch_associations
    artwork_requests.update_all(updated_at: Time.now)
    proofs.update_all(updated_at: Time.now) 
  end

  def assign_pending_selected_option_values
    return if @pending_selected_option_values.nil?

    imprint_option_values.destroy_all
    @pending_selected_option_values.each do |_option_type_id, option_value|
      next if option_value.blank?

      case option_value
      when String, Fixnum then option_value_id = option_value
      else                     option_value_id = option_value.id
      end

      imprint_option_values.create(option_value_id: option_value_id)
    end

    @pending_selected_option_values = nil
  end
end
