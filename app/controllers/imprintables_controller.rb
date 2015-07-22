class ImprintablesController < InheritedResources::Base
  before_action :set_current_action

  def index
    if (query = params[:q])
      @imprintables = Imprintable.search do
        fulltext query
      end
        .results

      if params[:respond_with_partial]
        respond_to do |format|
          format.js do
            render partial: params[:respond_with_partial],
                   locals: { imprintables: @imprintables }
          end
        end
      end
    else
      super do
        @imprintables = params[:tag] ? Imprintable.tagged_with(params[:tag]) : Imprintable.all.page(params[:page])
      end
    end
  end

  def new
    initialize_instance_hash
    super
  end

  def create
    initialize_instance_hash
    super
  end

  def update
    super do |success, failure|
      color_ids = (params[:color].nil? ? [] : params[:color][:ids])
      size_ids = (params[:size].nil? ? [] : params[:size][:ids])

      if color_ids && size_ids
        color_ids.each do |color_id|
          unless color_id.blank?
            size_ids.each do |size_id|
              unless color_id.blank?
                unless ImprintableVariant.new(imprintable_id: params[:id],
                                              size_id: size_id,
                                              color_id: color_id).save
                  flash[:error] = 'One or more of the imprintable variants could not be created.'
                end
              end
            end
          end
        end
      end

      update_imprintable_variant_weights params[:imprintable_variant_weights] unless params[:imprintable_variant_weights].nil?

      success.html { redirect_to edit_imprintable_path params[:id] }
      failure.html do
        initialize_instance_hash
        @instance_hash[:variants_hash] = set_variants_hash
        render :edit
      end
    end
  end

  def show
    super do |format|
      @imprintable = Imprintable.find(params[:id])
      @variants_hash = set_variants_hash

      format.html
      format.js
    end
  end

  def edit
    initialize_instance_hash
    super do
      @instance_hash[:variants_hash] = set_variants_hash
    end
  end

  def update_imprintable_variants
    if params.fetch(:update, []).is_a? Hash
      variants_to_add = params[:update][:variants_to_add]
      variants_to_remove = params[:update][:variants_to_remove]
    end

    variants_to_add ||= []
    variants_to_remove ||= []

    unless variants_to_add.empty?
      variants_to_add.each do |_key, value|
        size_id = value['size_id']
        color_id = value['color_id']
        unless size_id.blank? && color_id.blank?
          unless ImprintableVariant.new(imprintable_id: params[:id],
                                        size_id: size_id,
                                        color_id: color_id).save
            flash[:error] = 'One or more of the variants could not be saved.'
          end
        end
      end
    end

    variants_to_remove.each do |imprintable_variant_id|
      ImprintableVariant.delete(imprintable_variant_id)
    end

    render json: {}
  end

  protected

  def initialize_instance_hash
    @instance_hash = {}
    @instance_hash[:model_collection_hash] = Imprintable.set_model_collection_hash
  end


  def set_current_action
    @current_action = 'imprintables'
  end

  private

  def update_imprintable_variant_weights(imprintable_variant_weights)
    imprintable_variant_weights.each do |size_id, weight|
      size = Size.find(size_id)
      @imprintable.update_weights_for_size(size, weight)
    end
  end


  def set_variants_hash
    @imprintable.create_variants_hash
  end



  def permitted_params
    params.permit(
      :q, :respond_with_partial, :id,
      imprintable: [
        :water_resistance_level,
        :sleeve_type,
        :sleeve_length,
        :neck_style,
        :neck_size,
        :fabric_type,
        :is_stain_resistant,
        :fit_type,
        :fabric_wash,
        :department_name,
        :chest_size,
        :package_height,
        :package_width,
        :package_length,

        :flashable, :polyester, :special_considerations,
        :material, :brand_id, :style_name, :style_catalog_no,
        :style_description, :sku, :retail, :color_check,
        :size_check, :max_imprint_width, :max_imprint_height,
        :weight, :supplier_link, :main_supplier,
        :base_price, :xxl_price, :xxxl_price, :xxxxl_price, :xxxxxl_price,
        :base_price_ok, :xxl_price_ok, :xxxl_price_ok, :xxxxl_price_ok, :xxxxxl_price_ok,
        :xxxxxxl_price_ok, :base_upcharge,
        :xxxxxxl_price, :xxl_upcharge, :xxxl_upcharge, :xxxxl_upcharge,
        :xxxxxl_upcharge, :xxxxxxl_upcharge, :tag_list, :standard_offering,
        :proofing_template_name, :sizing_category, :common_name, :discontinued, :tag,
        sample_location_ids: [],
        coordinate_ids: [],
        compatible_imprint_method_ids: [],
        imprintable_categories_attributes: [
          :name, :imprintable_id, :id, :_destroy
        ],
        imprintable_variants_attributes: [
          :weight, :imprintable_id, :id
        ],
        imprintable_photos_attributes: [
          :id, :default, :color_id, :_destroy,
          asset_attributes: [
            :id, :file, :file_url, :_destroy,
          ]
        ],
        print_location_imprintables_attributes: [
          :id, :print_location_id, :max_imprint_width, :max_imprint_height, :_destroy
        ]
      ]
    )
  end
end
