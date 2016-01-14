class FbaProductsController < InheritedResources::Base
  def index
    @current_action = 'fba_products#index'
    @fba_products = FbaProduct.page(params[:page])
  end

  private

  def permitted_params
    params.permit(
      fba_products: [
        :name, :sku,
        fba_sku_attributes: [
          :sku, :imprintable_variant_id, :fba_job_template_id
        ]
      ]
    )
  end
end
