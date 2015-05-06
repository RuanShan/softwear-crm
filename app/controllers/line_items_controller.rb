class LineItemsController < InheritedResources::Base
  include BatchUpdate
  include LineItemHelper

  after_filter :assign_line_itemable, only: [:create]

  # before_filter :load_line_itemable,
                # except: [:select_options, :destroy, :update]

  def new
    super do |format|
      @line_item = @line_itemable.line_items.new

      format.html { render partial: 'create_modal' }
      format.js { render locals: { standard_only: params[:standard_only] } }
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
      format.js
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
      format.js
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
    batch_update do |format|
      logged = {}

      @line_items.each do |line_item|
        next if line_item.imprintable? && logged[line_item.name]

        fire_activity line_item, :update
        logged[line_item.name] = true if line_item.imprintable?
      end

      format.html { redirect_to root_path }
      format.js
    end
  end

  def create
    return create_imprintable if param_okay? :imprintable_id, :color_id

    super do |format|
      if @line_itemable.class.name == 'Quote'
        @line_itemable.create_activity :added_line_item,
                                        owner:  current_user,
                                        params: { name: @line_item.name }
      end

      fire_activity @line_item, :create if @line_item.valid?

      format.json(&method(:create_json))
      format.js { render locals: { success: @line_item.valid? } }
      format.html { redirect_to root_path }
    end
  end

  def select_options
    respond_to do |format|
      format.html do
        render(
          layout:   nil,
          template: select_options_template,
          locals:   select_options_locals
        )
      end
    end
  end

  def form_partial
    @line_item = LineItem.find params[:id]
  end

  private

  def create_json
    return render json: { result: 'success' } if @line_item.valid?

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

  def create_imprintable
    @line_items = LineItem.new_imprintables(
      @line_itemable,
      params[:imprintable_id],
      params[:color_id],
      base_unit_price: params[:base_unit_price]
    )

    return create_imprintable_failure unless @line_items.all?(&:valid?)
    create_imprintable_success
  end

  def create_imprintable_success
    @line_items.each(&:save)

    fire_activity @line_items.first, :create
    respond_to do |format|
      format.json { render json: { result: 'success' } }
      format.js { render locals: { success: true, line_items: @line_items } }
    end
  end

  def create_imprintable_failure
    modal_html = render_string(
      partial: 'shared/modal_errors',
      locals: { object: @line_items.reject(&:valid?).first }
    )
    errors = @line_items.map{ |l| l.errors.full_messages }.flatten.uniq

    respond_to do |format|
      format.json do
        render json: {
          result: 'failure',
          errors: errors,
          modal: modal_html
        }
      end
      format.html do
        redirect_to root_path
      end
      format.js { render locals: { success: false } }
    end
  end

  def select_options_locals
    if param_okay? :imprintable_id
      return select_style_locals([]) if select_imprintable.nil?
      return show_variants_locals    if param_okay? :color_id
      return select_color_locals
    else
      return select_style_locals if param_okay? :brand_id
      return select_brand_locals
    end
  end

  def select_options_template
    if param_okay?(:imprintable_id, :color_id)
      'line_items/selected_variants'
    else
      'line_items/select_options'
    end
  end

  def select_brand_locals
    {
      objects: Brand.all,
      type_name: Brand.name
    }
  end

  def select_style_locals(objects = nil)
    {
      objects: objects || Imprintable.where(brand_id: params[:brand_id]),
      type_name: Imprintable.name
    }
  end

  def select_imprintable
    Imprintable.find(params[:imprintable_id])
  end

  def select_variants
    ImprintableVariant.includes(:color).where(
      imprintable_id: select_imprintable.id
    )
  end

  def select_color_locals
    {
      objects: select_variants.map { |v| v.color }.uniq,
      type_name: Color.name
    }
  end

  def show_variants_locals
    variants = select_variants
    {
      objects: variants.includes(:size).where(color_id: params[:color_id]),
      imprintable_id: select_imprintable.id,
      color_id: params[:color_id]
    }
  end

  def destroy_multiple(ids, &respond)
    ids = ids.split('/').flatten.map(&:to_i)
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

  def param_okay?(atleast_one, *other_args)
    ([atleast_one] + other_args).all? do |param|
      params[param] && !params[param].try(:empty?)
    end
  end

  def entry_partial(kind)
    return 'imprintable_edit_entry' if @line_item.imprintable?
    "standard_#{kind}_entry"
  end

  def line_item_locals(edit = false)
    { line_item: @line_item, edit: edit }
  end

  def assign_line_itemable
    return unless @line_item && @line_item.line_itemable.nil?

    @line_item.line_itemable = @line_itemable
    flash[:error] = 'The line item was unable to be saved.' unless @line_item.save
  end

  def permitted_params
    params.permit(
      :brand_id, :color_id, :imprintable_id, :job_id,
      :standard_only, :ids, :standard,
      line_item: [
        :id, :name, :description, :quantity, :url,
        :unit_price, :imprintable_variant_id,
        :taxable
      ]
    )
  end

  def assign_line_itemable
    @line_itemable = @line_item.line_itemable
  end

end
