class FbaProductsController < InheritedResources::Base
  include ActionView::Helpers::FormOptionsHelper
  SelectOptions = Struct.new(:id, :target, :hide, :collection)
  SelectedOption = Struct.new(:id, :target, :value)

  before_filter :check_autofill, only: [:new, :edit, :create, :update]

  helper_method :imprintable_options_for_select
  helper_method :color_options_for_select
  helper_method :size_options_for_select

  def index
    @current_action = 'fba_products#index'
    @fba_products = FbaProduct.page(params[:page])
  end

  def new_from_spreadsheet
  end

  def upload_spreadsheet
    if params[:spreadsheet].blank?
      flash[:error] = "Looks like you forgot to choose a spreadsheet!"
      redirect_to new_from_spreadsheet_fba_products_path and return
    end

    @errors = FbaProduct.create_from_spreadsheet(params[:spreadsheet].path)
    if @errors.blank?
      flash[:success] = "Upload successful!"
    else
      error_message = "Parse errors: <br />"
      @errors.each do |sheet_name, sheet_errors|
        error_message += "=== Sheet: \"#{sheet_name}\" ==="
        error_message += "<br />"
        sheet_errors.each do |row_number, message|
          error_message += "Row #{row_number}: #{message}"
          error_message += "<br />"
        end
        error_message += "<br />"
      end
      flash[:error] = error_message.html_safe
    end

    redirect_to new_from_spreadsheet_fba_products_path
  end

  def variant_fields
    @results = []
    @selections = []

    if params[:sku] && params[:name]
      sku_info = FBA.parse_sku(params[:sku])

      imprintable = Imprintable.find_by sku: sku_info.imprintable
      color       = Color.find_by       sku: sku_info.color
      size        = Size.find_by        sku: sku_info.size
      return if imprintable.nil? || color.nil? || size.nil?
      variant = imprintable.imprintable_variants.where(color_id: color.id, size_id: size.id).first
      return if variant.nil?

      entry = {
        brand_id:       imprintable.brand_id,
        imprintable_id: imprintable.id,
        color_id:       color.id,
        id:             params[:name]
      }

      @results = [
        select_options_from_brand_id(entry),
        select_options_from_imprintable_id(entry),
        select_options_from_color_id(entry)
      ]

      @selections = [
        SelectedOption.new(params[:name], '.fba-sku-brand', imprintable.brand_id),
        SelectedOption.new(params[:name], '.fba-sku-style', imprintable.id),
        SelectedOption.new(params[:name], '.fba-sku-color', color.id),
        SelectedOption.new(params[:name], '.fba-sku-size',  variant.id)
      ]
    else
      # params[:entries] comes from assets/javascripts/fba_sku.js
      entries = params[:entries]

      entries.each do |_index, entry|
        if entry[:color_id]
          @results << select_options_from_color_id(entry)

        elsif entry[:imprintable_id]
          @results << select_options_from_imprintable_id(entry)

        elsif entry[:brand_id]
          @results << select_options_from_brand_id(entry)
        end
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
        :name, :sku,
        fba_skus_attributes: [
          :id, :sku, :imprintable_variant_id, :fba_job_template_id,
          :fnsku, :asin, :_destroy
        ]
      ]
    )
  end

  def check_autofill
    if params[:sku_autofill]
      session[:sku_autofill] = params[:sku_autofill]
    end
    if session[:sku_autofill].nil?
      @sku_autofill = true
    else
      @sku_autofill = session[:sku_autofill] == '1'
    end
  end
end
