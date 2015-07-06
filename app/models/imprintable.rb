class Imprintable < ActiveRecord::Base
  include Retailable

  # NOTE do try to keep the number values in these tier constants
  # consistent with the TIERS constant.
  TIER = OpenStruct.new(economy: 2, good: 3, better: 6, best: 9)

  TIERS = {
    2 => 'Economy',
    3 => 'Good',
    6 => 'Better',
    9 => 'Best'
  }

  WATER_RESISTANCE_LEVELS = [
    'not_water_resistant', 'water_resistant', 'waterproof'
  ]
  SLEEVE_TYPES = [
    '3/4 Sleeve', 'Cap Sleeve', 'Long Sleeve', 'Short Sleeve',
    'Sleeveless', 'Tanks'
  ]
  NECK_STYLES = [
    'Boat Neck', 'Cowl Neck', 'Crewneck', 'Eyelet', 'Halter',
    'Henley', 'High Neck', 'Hooded', 'Mock Neck', 'One Shoulder',
    'Racer Back', 'Scoop Neck', 'Strapless/Tube', 'Turtleneck',
    'V-Neck'
  ]
  FIT_TYPES = [
    'Loose', 'Overall', 'Regular', 'Relaxed', 'Skinny', 'Slim',
    'Strech', 'Western'
  ]
  FABRIC_WASHES = [
    'Dark', 'Light', 'Medium'
  ]
  DEPARTMENT_NAMES = [
    'baby-boys', 'baby-girls', 'boys', 'girls', 'mens',
    'unisex-adult (novelty and luggage only)', 'unisex-baby',
    'womens'
  ]


  acts_as_paranoid
  acts_as_taggable

  default_scope { eager_load(:brand)
                    .order('brands.name, imprintables.style_catalog_no')
                    .joins(:brand)
                    .readonly(false)
                    }


  paginates_per 50

  searchable do
    text :name,
         :special_considerations,
         :proofing_template_name,
         :main_supplier,
         :description

    text :all_categories
    text :compatible_print_methods

    string :sizing_category
    string :name
    float :base_price
    boolean :flashable
    boolean :standard_offering
    boolean :retail
    boolean :discontinued
  end

  SIZING_CATEGORIES = [
    'Adult Unisex',
    'Ladies',
    'Youth Unisex',
    'Girls',
    'Toddler',
    'Infant',
    'n/a'
  ]

  belongs_to :brand
  has_many :colors, ->{ uniq }, through: :imprintable_variants
  has_many :compatible_imprint_methods, through: :imprint_method_imprintables, source: :imprint_method
  has_many :coordinates, through: :coordinate_imprintables
  has_many :coordinate_imprintables
  has_many :imprint_method_imprintables
  has_many :imprintable_categories
  has_many :imprintable_stores
  has_many :imprintable_variants, dependent: :destroy
  has_many :mirrored_coordinates,
           through: :mirrored_coordinate_imprintables,
           source: :imprintable
  has_many :mirrored_coordinate_imprintables,
           class_name: 'CoordinateImprintable',
           foreign_key: 'coordinate_id'
  has_many :sample_locations, through: :imprintable_stores, source: :store
  has_many :sizes, ->{ uniq }, through: :imprintable_variants
  has_many :imprintable_imprintable_groups
  has_many :imprintable_groups, through: :imprintable_imprintable_groups
  has_many :similar_imprintables, through: :imprintable_groups, source: :imprintables
  has_many :imprintable_photos
  has_many :assets, through: :imprintable_photos

  accepts_nested_attributes_for :imprintable_categories,
                                :imprintable_imprintable_groups,
                                :imprintable_photos,
                                allow_destroy: true
  accepts_nested_attributes_for :imprintable_variants

  validates :brand, presence: true
 # validates :max_imprint_height, numericality: true, presence: false
 # validates :max_imprint_width, numericality: true, presence: false
  validates :sizing_category,
             inclusion: { in: SIZING_CATEGORIES, message: 'Invalid sizing category' }
  validates :sku, length: { is: 4 }, if: :is_retail?
  validates :style_catalog_no, uniqueness: { scope: :brand_id }, presence: true
  validates :style_name, uniqueness: { scope: :brand_id }, presence: true
  validates :common_name, uniqueness: true, if: :is_retail?
  validates :supplier_link,
             format: {
                        with: URI::regexp(%w(http https)),
                        message: 'should be in format http://www.url.com/path'
                     },
             allow_blank: true

  validates :imprintable_variants, :base_price, presence: true, unless: proc { imprintable_imprintable_groups.empty? }

  validates :water_resistance_level, inclusion: { in: WATER_RESISTANCE_LEVELS, message: "is not 'not_water_resistant', 'water_resistant', or 'waterproof'" }, if: :water_resistance_level
  validates :sleeve_type, inclusion: { in: SLEEVE_TYPES, message: "is not a valid sleeve type" }, if: :sleeve_type
  validates :neck_style, inclusion: { in: NECK_STYLES, message: "is not a valid neck style" }, if: :neck_style
  validates :fit_type, inclusion: { in: FIT_TYPES, message: "is not a valid fit type" }, if: :fit_type
  validates :fabric_wash, inclusion: { in: FABRIC_WASHES, message: "is not a valid fabric wash" }, if: :fabric_wash
  validates :department_name, inclusion: { in: DEPARTMENT_NAMES, message: "is not a valid department name" }, if: :department_name

  before_save :discontinue_imprintable, if: :discontinued?

  def self.find(param)
    unscoped.where(deleted_at: nil).find(param)
  end

  def photo_urls
    assets.map { |a| a.file.url(:medium) }
  end

  def compatible_print_methods
    compatible_imprint_methods.pluck(:name).join ' '
  end

  def all_categories
    imprintable_categories.pluck(:name).join ' '
  end

  def variants_of_color(color)
    imprintable_variants
      .joins(:color, :size)
      .where(colors: { name: color.try(:name) || color })
  end

  def sizes_by_color(color, size_options = nil)
    variants_of_color(color)
      .ergo { |v| v.where(sizes: size_options) if size_options }
      .map(&:size)
  end

  def create_imprintable_variants(from)
    from.fetch(:colors).each do |color|
      from.fetch(:sizes).each do |size|
        i = ImprintableVariant.unscoped.find_or_initialize_by(size_id: size.id,
                                                              color_id: color.id,
                                                              imprintable_id: id)
        i.deleted_at = nil
        return false unless i.save
      end
    end
  end

  def create_variants_hash
    variants_array = self.class.variants(id).to_a
    size_variants = variants_array.uniq(&:size_id)

    size_variants.sort! { |x,y| x.size.sort_order <=> y.size.sort_order }

    color_variants = variants_array.uniq(&:color_id).sort! {|x,y| x.color.name <=> y.color.name }
    {
      size_variants: size_variants,
      color_variants: color_variants,
      variants_array: variants_array
    }
  end

  def self.set_model_collection_hash
    model_collection_hash = {}
    model_collection_hash[:brand_collection] = Brand.order(:name).map{ |b| [b.name, b.id] }
    model_collection_hash[:store_collection] = Store.order(:name)
    model_collection_hash[:imprintable_collection] = Imprintable.all
    model_collection_hash[:size_collection] = Size.order(:sort_order)
    model_collection_hash[:color_collection] = Color.order(:name)
    model_collection_hash[:imprint_method_collection] = ImprintMethod.all
    model_collection_hash[:all_colors] = Color.all
    model_collection_hash[:all_sizes] = Size.all
    model_collection_hash
  end

  def description
    style_description
  end

  def determine_sizes(collection_proxy)
    if collection_proxy.first.nil?
      nil
    elsif collection_proxy.size == 1
      return collection_proxy.first.display_value
    else
      "#{collection_proxy.first.display_value} - #{collection_proxy.last.display_value}"
    end
  end

  def name
    "#{brand.try(:name) || '<no brand>'} - #{style_catalog_no} - #{style_name}"
  end

  def self.variants(id)
    ImprintableVariant.includes(:size, :color).where(imprintable_id: id)
  end

  def style_name_and_catalog_no
    "#{style_catalog_no} - #{style_name}"
  end

  def imprintable_variant_weight_for_size(size)
    imprintable_variants.where(size_id: size.id).maximum(:weight)
  end

  def update_weights_for_size(size, weight)
    weight = weight.to_f
    imprintable_variants.where(size_id: size.id).update_all(weight: weight)
  end

  def max_print_sizes_for_imprint(imprint_method)
    max_imprint_sizes = {}
    imprint_method.print_locations.each do |pl|
      max_imprint_sizes[pl.name] = {
          w: [max_imprint_width, pl.max_width].min,
          h: [max_imprint_height, pl.max_height].min,
          imprint_max: "#{pl.max_width}in x #{pl.max_height}in"
      }
    end
    max_imprint_sizes
  end

  def cant_be_added_to_quote_reason(view = nil)
    if discontinued?
      "Discontinued"
    elsif base_price.blank?
      msg = "Imprintable has no base price"
      if view
        msg + " #{view.link_to '(edit)', view.edit_imprintable_path(self), target: :_blank}"
      else
        msg
      end
    elsif imprintable_variants.empty?
      msg = "Imprintable has no imprintable variants"
      if view
        msg + " #{view.link_to '(edit)', view.edit_imprintable_path(self), target: :_blank}"
      else
        msg
      end
    end
  end

  %i(base xxl xxxl xxxxl xxxxxl xxxxxxl).each do |pre|
    # base_price_ok
    define_method "#{pre}_price_ok" do
      !send("#{pre}_price").nil?
    end
    # base_price_nil
    define_method "#{pre}_price_nil" do
      send("#{pre}_price").nil?
    end

    # imprintable.base_price_ok = false
    define_method "#{pre}_price_ok=" do |new_ok|
      if    new_ok == '1' || new_ok == 'true'  || new_ok == true
        new_ok = true
      elsif new_ok == '0' || new_ok == 'false' || new_ok == false
        new_ok = false
      end

      instance_variable_set("@#{pre}_price_ok", new_ok)
      instance_variable_set("@#{pre}_price_nil", !new_ok)
      send("#{pre}_price=", nil) unless new_ok
    end

    # if (for example):
    # base_price_ok = false was set,
    # make sure base_price is nil.
    # TODO this works but maybe actually test this stuff
    before_save do
      if instance_variable_get("@#{pre}_price_nil")
        send("#{pre}_price=", nil)

        instance_variable_set("@#{pre}_price_ok", nil)
        instance_variable_set("@#{pre}_price_nil", nil)
      end
    end
  end

  private

  def discontinue_imprintable
    self.imprintable_imprintable_groups.destroy_all
    self.standard_offering = false
    true
  end

end
