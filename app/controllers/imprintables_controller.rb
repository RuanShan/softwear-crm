class ImprintablesController < InheritedResources::Base


  def index
    super do
      if params[:tag]
        @imprintables = Imprintable.tagged_with(params[:tag])
      else
        @imprintables = Imprintable.all.page(params[:page])
      end
    end
  end

  def update
    super do |success, failure|
      color_ids = (params[:color].nil? ? [] : params[:color][:ids])
      size_ids = (params[:size].nil? ? [] : params[:size][:ids])
      if color_ids && size_ids
        color_ids.each do |color_id|
          size_ids.each do |size_id|
            ImprintableVariant.create(:imprintable_id => params[:id], :size_id => size_id, :color_id => color_id)
          end
        end
      end
      success.html { redirect_to edit_imprintable_path params[:id] }
      failure.html do
        set_variant_hashes
        render action: :edit
      end
    end
  end


  def show
    super do |format|
      @imprintable = Imprintable.find(params[:id])
      set_variant_hashes
      format.html
      format.js
      format.json { render json: @imprintable }
    end
  end

  def edit
    super do
      variants_hash = Imprintable.find(params[:id]).create_variants_hash
      @size_variants = variants_hash[:size_variants]
      @color_variants = variants_hash[:color_variants]
      @variants_array = variants_hash[:variants_array]
    end
  end

  def update_imprintable_variants
    if params[:update]
      variants_to_add = params[:update][:variants_to_add]
      variants_to_remove = params[:update][:variants_to_remove]
    end
    if !variants_to_add.nil?
      variants_to_add.each_value do |hash|
        size_id = hash['size_id']
        color_id = hash['color_id']
        ImprintableVariant.create(:imprintable_id => params[:id], :size_id => size_id, :color_id => color_id)
      end
    end
    if !variants_to_remove.nil?
      variants_to_remove.each do |imprintable_variant_id|
        ImprintableVariant.delete(imprintable_variant_id)
      end
    end
    render :json => {}
  end

  private

  def set_variant_hashes
    variants_hash = @imprintable.create_variants_hash
    @size_variants = variants_hash[:size_variants]
    @color_variants = variants_hash[:color_variants]
    @variants_array = variants_hash[:variants_array]
  end

  def permitted_params
    params.permit(imprintable:
                    [:flashable, :polyester, :special_considerations, :material, :brand_id,
                     :style_name, :style_catalog_no, :style_description, :sku, :retail, :color_check, :size_check, :weight, :supplier_link, :main_supplier,
                     :base_price, :xxl_price, :xxxl_price, :xxxxl_price, :xxxxxl_price, :xxxxxxl_price,
                     :tag_list, :standard_offering, :proofing_template_name, :sizing_category,
                     sample_location_ids: [],
                     coordinate_ids: [],
                     compatible_imprint_method_ids: [],
                     imprintable_categories_attributes: [:category, :imprintable_id, :id, :_destroy]])
  end
end
