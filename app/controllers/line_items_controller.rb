class LineItemsController < InheritedResources::Base
  before_filter :load_line_itemable, except: [:select_options, :destroy]

  def new
    super do |format|
      @line_item = @line_itemable.line_items.new
      format.html { render layout: nil }
    end
  end

  def index
    super do
      @line_items = @line_itemable.line_items
    end
  end

  def edit
    super do |format|
      format.html { render partial: 'standard_edit_entry', locals: { line_item: @line_item } }
      format.json do
        render json: {
          result: 'success',
          content: render_string(partial: 'standard_edit_entry', locals: { line_item: @line_item })
        }
      end
    end
  end

  def show
    super do |format|
      format.html do
        redirect_to order_path(@line_item.order, anchor: "jobs-#{@line_item.job.id}-line_item-#{@line_item.id}")
      end
      format.json do
        render json: {
          result: 'success',
          content: render_string(partial: 'standard_view_entry', locals: { line_item: @line_item })
        }
      end
    end
  end

  def destroy
    if params[:ids]
      ids = params[:ids].split('/').flatten.map(&:to_i)
      fire_activity LineItem.find(ids.first), :destroy unless ids.empty?
      
      LineItem.destroy ids
      render json: { result: 'success' }
    else
      super do |success, failure|
        success.json do
          fire_activity @line_item, :destroy
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
        fire_activity @line_item, :update
        with_format :html do
          content_html = render_to_string(partial: entry_partial('view'), locals: line_item_locals)
        end
        render json: { result: 'success', content: content_html }
      end
      success.html do
        fire_activity @line_item, :update
        render partial: 'standard_view_entry', locals: line_item_locals
      end

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
    if param_okay? :imprintable_id, :color_id # We create multiple line items for the variants
      line_items = ImprintableVariant.where(
        imprintable_id: params[:imprintable_id],
        color_id: params[:color_id]
      ).map { |variant|
        LineItem.new(
          imprintable_variant_id: variant.id,
          unit_price: params[:base_unit_price] || variant.imprintable.base_price || 0,
          quantity: 0,
          line_itemable_id: @line_itemable.id,
          line_itemable_type: @line_itemable.class.name
        )}

      valid_line_items = line_items.select(&:valid?)
      if !valid_line_items.empty?
        valid_line_items.each(&:save)

        fire_activity valid_line_items.first, :create
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
    else # Create a standard, non-imprintable line item
      super do |success, failure|
        success.json do
          @line_item.line_itemable_id = @line_itemable.id
          @line_item.line_itemable_type = @line_itemable.class.name
          @line_item.save
          fire_activity @line_item, :create
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

    if param_okay? :imprintable_id
      # Get colors from style
      imprintable = Imprintable.find(params[:imprintable_id])
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
        objects: Imprintable.where(brand_id: params[:brand_id]),
        type_name: Imprintable.name
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

  def form_partial
    @line_item = LineItem.find params[:id]
  end

private
  def permitted_params
    params.permit(
      :brand_id, :color_id, :imprintable_id, :job_id,
      :ids, :standard,
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

  def load_line_itemable
    if params[:id]
      line_item = LineItem.find(params[:id])
      klass = line_item.line_itemable_type.constantize
      @line_itemable = klass.find(line_item.line_itemable_id)
    else
      klass = [Job, Quote].detect { |li| params["#{li.name.underscore}_id"] }
      @line_itemable = klass.find(params["#{klass.name.underscore}_id"])
    end
  end
end
