class LineItemsController < InheritedResources::Base
  def new
    super do |format|
      format.html { render layout: nil, locals: { job: Job.find(params[:job_id]) } }
    end
  end

  def create
    super do |success, failure|
      success.json do
        render json: { result: 'success' }
      end
      failure.json do
        modal_html = 'ERROR'
        with_format :html do
          modal_html = render_to_string(partial: 'shared/modal_errors', locals: { object: @line_item })
        end
        render json: {
          result: 'failure',
          errors: @line_item.errors.messages,
          modal: modal_html
        }
      end
    end
  end

  def select_options
    render_options = { layout: nil }

    if param_okay? :style_id
      # Get colors from style
      imprintable = Imprintable.where(style_id: params[:style_id]).first
      if imprintable.nil?
        render_options[:locals] = {
          objects: [],
          type_name: Imprintable.name
        }
      else
        variants = ImprintableVariant.includes(:color).where(
          imprintable_id: imprintable.id
        )
        if param_okay? :color_id
          # Get imprintable variants from the imprintable + color id
          render_options[:locals] = {
            objects: variants.includes(:size).where(color_id: params[:color_id]),
            imprintable_id: imprintable.id,
            color_id: params[:color_id]
          }
          render_options[:template] = 'line_items/selected_variants'
        else
          render_options[:locals] = {
            objects: variants.map { |v| v.color }.uniq,
            type_name: Color.name
          }
        end
      end
    elsif param_okay? :brand_id
      # Get styles from brand
      render_options[:locals] = {
        objects: Style.where(brand_id: params[:brand_id]),
        type_name: Style.name
      }
    else
      # Get all brands
      render_options[:locals] = {
        objects: Brand.all,
        type_name: Brand.name
      }
    end
    render render_options
  end

private
  def permitted_params
    params.permit(:brand_id, :style_id, :color_id, 
      line_item: [
      :id, :name, :description, :quantity, 
      :unit_price, :imprintable_variant_id
    ])
  end

  def param_okay?(param)
    params[param] && !params[param].empty?
  end
end
