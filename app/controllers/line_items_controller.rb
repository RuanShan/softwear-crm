class LineItemsController < InheritedResources::Base
  def new
    super do |format|
      format.html { render layout: nil, locals: { job: Job.find(params[:job_id]) } }
    end
  end

  def edit
    super do |format|
      format.html { render partial: 'standard_edit_entry', locals: { line_item: @line_item } }
    end
  end

  def show
    super do |format|
      format.html { render partial: 'standard_view_entry', locals: { line_item: @line_item } }
    end
  end

  def destroy
    if params[:ids]
      LineItem.destroy params[:ids].split('/').flatten.map { |e| e.to_i }
      render json: { result: 'success' }
    else
      super do |success, failure|
        success.json do
          render json: { result: 'success' }
        end
        failure.json do
          render json: { result: 'failure' }
        end
      end
    end
  end

  def update
    super do |success, failure|
      success.json do
        content_html = ''
        with_format :html do
          content_html = render_to_string(partial: entry_partial('view'), locals: line_item_locals)
        end
        render json: { result: 'success', content: content_html }
      end
      success.html { render partial: 'standard_view_entry', locals: line_item_locals }

      failure.json do
        modal_html = ''
        form_html = ''
        with_format :html do
          form_html = render_to_string(partial: entry_partial('edit'), locals: line_item_locals(true))
        end
        with_format :html do
          modal_html = render_to_string(partial: 'shared/modal_errors', locals: { object: @line_item })
        end
        render json: { 
          result: 'failure',
          errors: @line_item.errors.messages,
          modal: modal_html,
          content: form_html
        }
      end
      failure.html { render partial: entry_partial('edit'), locals: line_item_locals(true) }
    end
  end

  def create
    if param_okay? :imprintable_id, :color_id
      line_items = ImprintableVariant.where(
        imprintable_id: params[:imprintable_id],
        color_id: params[:color_id]
      ).map { |variant|
        LineItem.new(
          imprintable_variant_id: variant.id,
          unit_price: 0,
          quantity: 0,
          job_id: params[:job_id]
      )}
      valid_line_items = line_items.map { |l| l.valid? ? 1 : 0 }.sum
      if valid_line_items > 0
        line_items.each { |l| l.save if l.valid? }
        render json: { result: 'success' }
      else
        modal_html = ''
        line_item = nil; line_items.each { |l| line_item = l unless l.valid? }
        with_format :html do
          modal_html = render_to_string(partial: 'shared/modal_errors', locals: { object: line_item })
        end
        render json: {
          result: 'failure',
          errors: line_item.errors.messages,
          modal: modal_html
        }
      end
    else
      super do |success, failure|
        success.json do
          @line_item.job_id = params[:job_id]
          @line_item.save
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
    params.permit(
      :brand_id, :style_id, :color_id, :imprintable_id, :job_id,
      :ids,
      line_item: [
      :id, :name, :description, :quantity, 
      :unit_price, :imprintable_variant_id,
      :taxable
    ])
  end

  def param_okay?(*args)
    result = true
    args.each do |param|
      result &&= params[param] && !params[param].empty?
    end
    result
  end

  def entry_partial(kind)
    @line_item.imprintable? ? 'imprintable_edit_entry' : "standard_#{kind}_entry"
  end
  def line_item_locals(edit = false)
    {line_item: @line_item, edit: edit}
  end
end
