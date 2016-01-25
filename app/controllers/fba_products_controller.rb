class FbaProductsController < InheritedResources::Base
  include ActionView::Helpers::FormOptionsHelper
  SelectOptions = Struct.new(:id, :target, :hide, :collection)

  helper_method :imprintable_options_for_select
  helper_method :color_options_for_select
  helper_method :size_options_for_select

  def index
    @current_action = 'fba_products#index'
    @fba_products = FbaProduct.page(params[:page])
  end

  def variant_fields
    @results = []
    # params[:entries] comes from assets/javascripts/fba_sku.js
    params[:entries].each do |_index, entry|
      if entry[:color_id]
        @results << select_options_from_color_id(entry)

      elsif entry[:imprintable_id]
        @results << select_options_from_imprintable_id(entry)

      elsif entry[:brand_id]
        @results << select_options_from_brand_id(entry)
      end
    end

    respond_to(&:js)
  end

  private

  # == Helper methods used in fba_products/_fba_sku_fields.html.erb ==
  def imprintable_options_for_select(fba_sku)
    return "" if fba_sku.imprintable_variant.nil? || fba_sku.brand.nil?

    options_from_collection_for_select(
      imprintable_ids_from_brand(fba_sku.brand.id),
      :first, :last,
      fba_sku.imprintable_variant.imprintable_id
    )
  end

  def color_options_for_select(fba_sku)
    return "" if fba_sku.imprintable_variant.nil?

    options_from_collection_for_select(
      color_ids_from_imprintable(fba_sku.imprintable_variant.imprintable_id),
      :first, :last,
      fba_sku.imprintable_variant.color_id
    )
  end

  def size_options_for_select(fba_sku)
    return "" if fba_sku.imprintable_variant.nil?

    options_from_collection_for_select(
      variants_from_imprintable_and_color(
        fba_sku.imprintable_variant.imprintable_id,
        fba_sku.imprintable_variant.color_id
      ),
      :id, :size_display,
      fba_sku.imprintable_variant_id
    )
  end


  # == grabbing records and turning them into select2-friendly data arrays ==
  def variants_from_imprintable_and_color(imprintable_id, color_id)
    ImprintableVariant
      .includes(:size)
      .joins(:color)
      .where(imprintable_id: imprintable_id)
      .where(colors: { id: color_id })
      .uniq(&:id)
      .sort_by { |v| v.size.sort_order }
  end

  def select_options_from_color_id(entry)
    raise "Imprintable ID shouldn't be blank here" if entry[:imprintable_id].blank?
    result = SelectOptions.new

    result.id = entry[:id]
    result.target = '.fba-sku-size'
    result.hide = []
    result.collection = variants_from_imprintable_and_color(entry[:imprintable_id], entry[:color_id])
      .map { |v| { id: v.id, text: v.size_display } }

    result
  end

  def color_ids_from_imprintable(imprintable_id)
    Color
      .joins(:imprintables)
      .where(imprintables: { id: imprintable_id })
      .pluck(:id, :name)
      .uniq { |c| c[0] }
  end

  def select_options_from_imprintable_id(entry)
    result = SelectOptions.new

    result.id = entry[:id]
    result.target = '.fba-sku-color'
    result.hide = ['.fba-sku-size']
    result.collection = color_ids_from_imprintable(entry[:imprintable_id])
      .map { |c| { id: c[0], text: c[1] } }

    result
  end

  def imprintable_ids_from_brand(brand_id)
    Imprintable
      .where(brand_id: brand_id)
      .pluck(:id, :style_catalog_no)
  end

  def select_options_from_brand_id(entry)
    result = SelectOptions.new

    result.id = entry[:id]
    result.target = '.fba-sku-style'
    result.hide = ['.fba-sku-color', '.fba-sku-size']
    result.collection = imprintable_ids_from_brand(entry[:brand_id])
      .map { |s| { id: s[0], text: s[1] } }
    result
  end

  def permitted_params
    params.permit(
      fba_product: [
        :name, :sku, :fnsku,
        fba_skus_attributes: [
          :id, :sku, :imprintable_variant_id, :fba_job_template_id, :_destroy
        ]
      ]
    )
  end
end
