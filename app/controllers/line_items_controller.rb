class LineItemsController < InheritedResources::Base
  include BatchUpdate
  include LineItemHelper

  belongs_to :job, optional: true

  def new
    super do |format|
      # @line_item = @line_itemable.line_items.new
      @job = @line_itemable = Job.find(params[:job_id])

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
        redirect_to edit_order_path(
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
    if params[:id].include? '/'
      destroy_multiple params[:id] do |format|
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

      order = nil
      @line_items.each { |li| order = li.order and break if li.order? }

      # `logged` being not empty implies that imprintable line items were changed
      if !logged.empty? && order.production?
        OrderMailer.imprintable_line_items_changed(
          order,
          edit_order_url(order),
          order.production_url
        )
          .deliver_now
      end

      format.html { redirect_to root_path }
      format.js
    end
  end

  def create
    @line_itemable = Job.find(params[:job_id])

    return create_imprintable if param_okay? :imprintable_id, :color_id

    super do |format|
      if @line_itemable.class.name == 'Quote'
        @line_itemable.create_activity :added_line_item,
                                        owner:  current_user,
                                        params: { name: @line_item.name }
      end
      if @line_itemable.try(:jobbable).try(:markups_and_options_job) == @line_item.line_itemable
        Quote.public_activity_on
        quote = @line_itemable.jobbable
        quote.create_activity key: "quote.add_a_markup", owner: current_user, parameters: @line_item.markup_hash(@line_item)
        Quote.public_activity_off
      end

      format.json(&method(:create_json))
      format.js do
        if params[:quote_update]
          @quote = Quote.find(params[:quote_update])
          render 'quotes/update'
        else
          render locals: { success: @line_item.valid? }
        end
      end
      format.html do
        redirect_to params[:done_path] || root_path
      end
    end
  end

  def create_from_quotes
    @job = Job.find(params[:job_id])
    @succeeded_line_items = []
    @failed_line_items = []

    params[:line_items].each do |line_item_id, attrs|
      next unless attrs[:included]

      quote_line_item = LineItem.find(line_item_id)
      raise "Expected non-variant imprintable line item" unless quote_line_item.imprintable_object_type == "Imprintable"
      raise "Expected color ID to be present" if attrs[:color_id].blank?

      line_items = LineItem.new_imprintables(
        @job,
        quote_line_item.imprintable_object_id,
        attrs[:color_id],
        imprintable_price: attrs[:imprintable_price],
        decoration_price:  attrs[:decoration_price]
      )

      line_items.each do |line_item|
        if line_item.save
          @succeeded_line_items << line_item
        else
          @failed_line_items << line_item
        end
      end
    end

    respond_to do |format|
      format.js
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

  def update_sort_orders
    @line_item_ids = params[:categories]

    ActiveRecord::Base.transaction do
      @line_item_ids.each_with_index do |id, n|
        LineItem.find(id).update(sort_order: n+1)
      end
    end

    render json: {}
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
      imprintable_price: params[:imprintable_price],
      decoration_price:  params[:decoration_price]
    )

    return create_imprintable_failure unless @line_items.all?(&:save)
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

    LineItem.destroy ids.select { |id| LineItem.where(id: id).exists? }

    respond_to(&respond)
  end

  def destroy_single(id)
    @line_item = LineItem.unscoped.find(id)
    @line_item.destroy

    respond_to do |format|
      yield format, !@line_item.deleted_at.nil?
    end
  end

  def param_okay?(atleast_one, *other_args)
    ([atleast_one] + other_args).all? do |param|
      params[param] && !params[param].try(:empty?)
    end
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
        :imprintable_id,
        :taxable, :line_itemable_id, :line_itemable_type
      ]
    )
  end

end
