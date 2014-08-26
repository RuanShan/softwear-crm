class ImprintablesController < InheritedResources::Base
  before_action :set_current_action

  def index
    super do
      # TODO: ternary with parenthesis
      @imprintables = params[:tag] ? (Imprintable.tagged_with(params[:tag])) : (Imprintable.all.page(params[:page]))
    end
  end

  def new
    super do
      set_model_collection_hash
    end
  end

  def update
    super do |success, failure|
      color_ids = (params[:color].nil? ? [] : params[:color][:ids])
      size_ids = (params[:size].nil? ? [] : params[:size][:ids])

      if color_ids && size_ids
        color_ids.each do |color_id|
          size_ids.each do |size_id|
            ImprintableVariant.create(imprintable_id: params[:id], size_id: size_id, color_id: color_id)
          end
        end
      end

      success.html { redirect_to edit_imprintable_path params[:id] }
      failure.html do
        set_model_collection_hash
        set_variants_hash
        render action: :edit
      end
    end
  end

  def show
    super do |format|
      @imprintable = Imprintable.find(params[:id])
      set_model_collection_hash
      set_variants_hash
      format.html
      format.js
    end
  end

  def edit
    set_model_collection_hash
    super do
      set_variants_hash
    end
  end

  def update_imprintable_variants
    if params.fetch(:update).is_a? Hash
      variants_to_add = params[:update][:variants_to_add]
      variants_to_remove = params[:update][:variants_to_remove]
    end

    variants_to_add ||= []
    variants_to_remove ||= []

    unless variants_to_add.empty?
      variants_to_add.each_value do |hash|
        size_id = hash['size_id']
        color_id = hash['color_id']
        ImprintableVariant.create(imprintable_id: params[:id], size_id: size_id, color_id: color_id)
      end
    end

    unless variants_to_remove.empty?
      variants_to_remove.each do |imprintable_variant_id|
        ImprintableVariant.delete(imprintable_variant_id)
      end
    end

    render json: {}
  end

  protected

  def set_current_action
    @current_action = 'imprintables'
  end

  private

  def set_variants_hash
    @variants_hash = @imprintable.create_variants_hash
  end

  def set_model_collection_hash
    @model_collection_hash = {}
    @model_collection_hash[:brand_collection] = Brand.order(:name).map{ |b| [b.name, b.id] }
    @model_collection_hash[:store_collection] = Store.order(:name)
    @model_collection_hash[:imprintable_collection] = Imprintable.all
    @model_collection_hash[:size_collection] = Size.order(:sort_order)
    @model_collection_hash[:color_collection] = Color.order(:name)
    @model_collection_hash[:imprint_method_collection] = ImprintMethod.all
    @model_collection_hash[:all_colors] = Color.all
    @model_collection_hash[:all_sizes] = Size.all
  end

  def permitted_params
    params.permit(imprintable:
                    [
                      :flashable, :polyester, :special_considerations,
                      :material, :brand_id, :style_name, :style_catalog_no,
                      :style_description, :sku, :retail, :color_check,
                      :size_check, :max_imprint_width, :max_imprint_height,
                      :weight, :supplier_link, :main_supplier, :base_price,
                      :xxl_price, :xxxl_price, :xxxxl_price, :xxxxxl_price,
                      :xxxxxxl_price, :tag_list, :standard_offering,
                      :proofing_template_name, :sizing_category,
                      sample_location_ids: [],
                      coordinate_ids: [],
                      compatible_imprint_method_ids: [],
                      imprintable_categories_attributes:
                        [
                          :name, :imprintable_id, :id, :_destroy
                        ]
                    ]
    )
  end
end
