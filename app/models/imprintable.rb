class Imprintable < ActiveRecord::Base
  include PricingModule
  include Retailable

  acts_as_paranoid
  acts_as_taggable

  default_scope { eager_load(:brand)
                    .order('brands.name, imprintables.style_catalog_no')
                    .joins(:brand)
                    .readonly(false) }

  paginates_per 50

  searchable do
    text :name,
         :special_considerations,
         :proofing_template_name,
         :main_supplier,
         :description

    text :all_categories

    string :sizing_category
    string :name
    float :base_price
    boolean :flashable
    boolean :standard_offering
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

  accepts_nested_attributes_for :imprintable_categories, allow_destroy: true

  validates :brand, presence: true
  validates :max_imprint_height, numericality: true, presence: true
  validates :max_imprint_width, numericality: true, presence: true
  validates :sizing_category,
             inclusion: { in: SIZING_CATEGORIES, message: 'Invalid sizing category' }
  validates :sku, length: { is: 4 }, if: :is_retail?
  validates :style_catalog_no, uniqueness: { scope: :brand_id }, presence: true
  validates :style_name, uniqueness: { scope: :brand_id }, presence: true
  validates :supplier_link,
             format: {
                        with: URI::regexp(%w(http https)),
                        message: 'should be in format http://www.url.com/path'
                     },
             allow_blank: true

  def all_categories
    imprintable_categories.map(&:name).join ' '
  end

  def create_imprintable_variants(from)
    from.fetch(:colors).each do |color|
      from.fetch(:sizes).each do |size|
        i = ImprintableVariant.unscoped.find_or_initialize_by(size_id: size.id,
                                                              color_id: color.id,
                                                              imprintable_id: id)
        i.deleted_at = nil
        i.save
      end
    end
  end

  def create_variants_hash
    variants_array = self.class.variants(id).to_a
    size_variants = variants_array.uniq(&:size_id)

    size_variants.sort! { |x,y| x.size.sort_order <=> y.size.sort_order }

    color_variants = variants_array.uniq(&:color_id)
    {
        size_variants: size_variants,
        color_variants: color_variants,
        variants_array: variants_array
    }
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
    "#{brand.try(:name) || '<no brandbrand>'} - #{style_catalog_no} - #{style_name}"
  end

  def pricing_hash(decoration_price)
    sizes_string = determine_sizes(sizes)
    {
        name: name,
        supplier_link: supplier_link,
        sizes: sizes_string,
        prices: get_prices(self, decoration_price)
    }
  end

  def self.variants(id)
    ImprintableVariant.includes(:size, :color).where(imprintable_id: id)
  end

  def style_name_and_catalog_no
    "#{style_catalog_no} - #{style_name}"
  end
end
