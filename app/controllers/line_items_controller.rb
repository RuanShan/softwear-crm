class LineItemsController < InheritedResources::Base
  include LineItemHelper

  before_filter :load_line_itemable, except: [:select_options, :destroy, :update]

  def new
    super do |format|
      @line_item = @line_itemable.line_items.new
      # TODO make this actually render the new page
      format.html { render partial: 'create_modal' }
      format.js
    end
  end

  def index
    super do
      @line_items = @line_itemable.line_items
    end
  end

  def edit
    super do |format|
      format.html do
        render partial: 'standard_edit_entry', locals: { line_item: @line_item }
      end
      format.json do
        render json: {
          result: 'success',
          content: render_string(
            partial: 'standard_edit_entry', locals: { line_item: @line_item }
          )
        }
      end
      format.js do
        render
      end
    end
  end

  def show
    super do |format|
      format.html do
        redirect_to order_path(
          @line_item.order,
          anchor: "jobs-#{@line_item.job.id}-line_item-#{@line_item.id}"
        )
      end
      format.json do
        render json: {
          result: 'success',
          content: render_string(
            partial: 'standard_view_entry',
            locals: { line_item: @line_item }
          )
        }
      end
      format.js do
        render
      end
    end
  end

  def destroy
    if param_okay? :ids
      destroy_multiple params[:ids] do |format|
        format.json { render json: { result: 'success' } }
        format.js do
          render locals: {
            success: true,
            selector: line_item_id(@line_item)
          }
        end
      end
    else
      destroy_single params[:id] do |format, success|
        if @line_itemable.is_a? Quote
          @line_itemable.create_activity :destroyed_line_item, 
            owner: current_user,
            params: { name: @line_item.name }
        end

        fire_activity @line_item, :destroy if success

        format.json do
          render json: { result: success ? 'success' : 'failure' }
        end
        format.js { render locals: { success: success } }
      end
    end
  end

  def update
#    super do |success, failure|
#      success.json do
#        if @line_itemable.is_a? Quote
#          @line_itemable.create_activity :updated_line_item, 
#            owner: current_user,
#            params: { name: @line_item.name }
#        end
#
#        fire_activity @line_item, :update
#        content_html = render_string partial: entry_partial('view'),
#                                     locals: line_item_locals
#
#        render json: { result: 'success', content: content_html }
#      end
#      success.html do
#        fire_activity @line_item, :update
#        render partial: 'standard_view_entry', locals: line_item_locals
#      end
#
#      success.js do
#        raise 'js cool'
#      end
#      failure.js do
#        raise 'js cool (but i failed)'
#      end
#
#      failure.json do
#        modal_html = render_string partial: entry_partial('edit'), 
#                                   locals: line_item_locals(true)
#        
#        error_html = render_string partial: 'shared/modal_errors', 
#                                   locals: { object: @line_item }
#
#        render json: { 
#          result: 'failure',
#          errors: @line_item.errors.messages,
#          modal: modal_html,
#          content: error_html
#        }
#      end
#      failure.html do
#        render partial: entry_partial('edit'), locals: line_item_locals(true)
#      end
#    end
    params.permit(:line_item).permit!

    line_item_attributes = params[:line_item].to_hash
    @line_items = line_item_attributes.keys.map(&LineItem.method(:find))

    @line_items.each do |line_item|
      line_item.update_attributes(line_item_attributes[line_item.id.to_s])
    end

    respond_to do |format|
      format.html do
        redirect_to root_path
      end
      format.js
    end
  end

  def create
    if param_okay? :imprintable_id, :color_id
      line_items = LineItem.new_imprintables(
        @line_itemable,
        params[:imprintable_id], params[:color_id],
        base_unit_price: params[:base_unit_price]
      )

      valid_line_items = line_items.select(&:valid?)
      if valid_line_items.empty?
          modal_html = render_string(
          partial: 'shared/modal_errors',
          locals: { object: line_items.first }
        )
        errors = line_items.map{ |l| l.errors.full_messages }.flatten.uniq

        render json: {
          result: 'failure',
          errors: errors,
          modal: modal_html
        }
      else
        valid_line_items.each(&:save)

        fire_activity valid_line_items.first, :create
        respond_to do |format|
          format.json { render json: { result: 'success' } }
          format.js
        end
      end
    else # Create a standard, non-imprintable line item
      super do |success, failure|
        if @line_itemable.class.name == 'Quote'
          @line_itemable.create_activity :added_line_item, 
            owner:  current_user,
            params: { name: @line_item.name }
        end

        success.json do
          @line_item.line_itemable_id = @line_itemable.id
          @line_item.line_itemable_type = @line_itemable.class.name
          @line_item.save
          fire_activity @line_item, :create
          render json: { result: 'success' }
        end

        success.js do
          render locals: { success: true }
        end
        failure.js do
          render locals: { success: false }
        end

        failure.json do
          modal_html = render_string(
            partial: 'shared/modal_errors',
            locals: { object: @line_item }
          )

          render json: {
            result: 'failure',
            errors: @line_item.errors.messages,
            modal: modal_html
          }
        end
      end
    end
  end

  # Probably this, too should be in the model
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
      ]
    )
  end

  def destroy_multiple(ids, &respond)
    ids = ids.split('/').flat_map(&:to_i)
    @line_item = LineItem.find(ids.first)
    fire_activity @line_item, :destroy unless ids.empty?

    LineItem.destroy ids

    respond_to(&respond)
  end

  def destroy_single(id)
    @line_item = LineItem.find(id)
    @line_item.destroy

    respond_to do |format|
      yield format, @line_item.destroyed?
    end
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
