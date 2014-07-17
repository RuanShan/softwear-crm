class Imprintable < ActiveRecord::Base
  include PricingModule

  paginates_per 50

  acts_as_paranoid
  acts_as_taggable

  SIZING_CATEGORIES = ['Adult Unisex', 'Ladies', 'Youth Unisex', 'Girls', 'Toddler', 'Infant', 'n/a']

  belongs_to :style
  has_one :brand, through: :style, dependent: :destroy
  has_many :imprintable_variants, dependent: :destroy
  has_many :colors, ->{ uniq }, through: :imprintable_variants, dependent: :destroy
  has_many :sizes, ->{ uniq },  through: :imprintable_variants, dependent: :destroy
  has_many :coordinate_imprintables
  has_many :coordinates, through: :coordinate_imprintables
  has_many :mirrored_coordinate_imprintables, class_name: 'CoordinateImprintable', foreign_key: 'coordinate_id'
  has_many :mirrored_coordinates, through: :mirrored_coordinate_imprintables, source: :imprintable
  has_many :imprintable_categories
  accepts_nested_attributes_for :imprintable_categories, allow_destroy: true
  has_and_belongs_to_many :sample_locations, class_name: 'Store', association_foreign_key: 'store_id', join_table: 'imprintables_stores'
  has_and_belongs_to_many :compatible_imprint_methods, class_name: 'ImprintMethod', association_foreign_key: 'imprint_method_id', join_table: 'imprint_methods_imprintables'

  validates :style, presence: true
  validates :sizing_category, inclusion: { in: SIZING_CATEGORIES, message: 'Invalid sizing category' }
  validates :supplier_link, format: {with: URI::regexp(%w(http https)), message: 'should be in format http://www.url.com/path'}, allow_blank: true

  default_scope { eager_load(:style, :brand).order('brands.name, styles.catalog_no').joins(:brand).readonly(false) }
  searchable do
    text :name, :special_considerations, :proofing_template_name, :main_supplier, :description
    text :all_categories

    string :sizing_category
    string :name # <- this can be removed; used to test stuff.
    float :base_price
    boolean :flashable
    boolean :standard_offering
  end

  def all_categories
    imprintable_categories.map(&:name).join ' '
  end

  def name
    "#{brand.name} - #{style.catalog_no} - #{style.name}"
  end

  def description
    style.description
  end

  def find_variants
    if self.id
      ImprintableVariant.includes(:size, :color).where(imprintable_id: self.id)
    end
  end

  def create_variants_hash
    variants = self.find_variants
    variants_array = variants.to_a
    size_variants = variants_array.uniq{ |v| v.size_id }
    size_variants.sort! { |x,y| x.size.sort_order <=> y.size.sort_order }

    color_variants = variants_array.uniq{ |v| v.color_id }
    { :size_variants => size_variants, :color_variants => color_variants, :variants_array => variants_array }
  end

  def standard_offering?
    standard_offering == true
  end

  def retail_sku

  end

  def pricing_hash(decoration_price)
    imprintable = self
    sizes_string = determine_sizes(imprintable.sizes)
    {
        name: imprintable.name,
        supplier_link: imprintable.supplier_link,
        sizes: sizes_string,
        prices: get_prices(imprintable, decoration_price)
    }
  end

  def determine_sizes(collection_proxy)
    if collection_proxy.first == nil
      return nil
    elsif collection_proxy.first == collection_proxy.last
      return collection_proxy.first.display_value
    else
      return "#{collection_proxy.first.display_value} - #{collection_proxy.last.display_value}"
    end
  end

  def create_imprintable_variants_from_sizes_and_colors(sizes=[], colors=[])
    colors.each do |color|
      sizes.each do |size|
        i = ImprintableVariant.unscoped.find_or_initialize_by(size_id: size.id, color_id: color.id, imprintable_id: self.id)
        i.deleted_at = nil
        i.save
      end
    end
  end
end
