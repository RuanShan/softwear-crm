class JobsController < InheritedResources::Base
  belongs_to :order, optional: true
  respond_to :json

  def update
    @job = Job.unscoped.find(params[:id])
    @li_old = @job.line_items.to_a
    @imprint_old = @job.imprints.to_a
    Job.public_activity_off if quote?
    super do |success, failure|
      success.json do
        render json: { result: 'success' }
    end
      failure.json do
        modal_html = 'ERROR'
        modal_html = render_string(partial: 'shared/modal_errors',
                                   locals: { object: @job })

        render json: {
          result: 'failure',
          errors: @job.errors.messages,
          modal:  modal_html
        }
      end

      @line_items = @job.line_items
      @imprints   = @job.imprints

      # [success, failure].each(&:js)
      failure.js
      success.js do |format|
        Job.public_activity_on if quote?
        @job.create_activity(
            key: 'quote.updated_line_item',
            parameters: @job.jobbable.activity_parameters_hash_for_job_changes(@job, @li_old, @imprints_old)
        ) if @job.jobbable_type = 'Quote'
        Job.public_activity_off if quote?
        format.js
      end
    end
  end

  def create
    super do |success, failure|
      success.html do
        render partial: 'job', locals: { job: @job, animated: true }
      end

      success.js
      failure.js

      failure.json do
        render json: {
          result: 'failure',
          errors: @job.errors.full_messages
        }
      end
    end

  end

  def destroy
    super do |success, failure|
      success.json do
        render json: {
          result: 'success',
          error: nil
        }
      end

      failure.json do
        render json: {
          result: 'failure',
          error: @job.errors.messages[:deletion_status]
        }
      end

      success.js
      failure.js
    end
  end

  def show
    super do |format|
      format.html do
        if @job.jobbable_type == 'Order'
          redirect_to order_path(@job.order, anchor: "jobs-#{@job.id}")
        else
          redirect_to edit_quote_path(@job.jobbable, anchor: 'line_items')
        end
      end
      format.json do
        render json: {
          result: 'success', content: render_string(partial: 'job', locals: { job: @job })
        }
      end
    end
  end

  def new
    super do |format|
      format.js
    end
  end

  def names_numbers
    @job = Job.find(params[:id])
    filename = "order_#{@job.order.name}_job_#{@job.name}_names_numbers.csv"

    send_data @job.name_number_csv, filename: sanitize_filename(filename)
  end

  private

  def quote?
    @job.try(:jobbable_type) == 'Quote'
  end

  def permitted_params
    line_items_attributes = [
      :id, :job_id, :tier, :description, :quantity,
      :unit_price, :imprintable_price, :decoration_price,
      :line_itemable_id,
      :_destroy
    ]
    tiered_line_item_attributes = Imprintable::TIERS.values.reduce({}) do |hash, tier_name|
      hash.merge("#{Job.tier_line_items_sym(tier_name)}_attributes" => line_items_attributes)
    end

    params.permit(
      :order_id, :job_id, :ids,

      job: [
        :id, :name, :description, :collapsed,
        {
          line_items_attributes: line_items_attributes,
          imprints_attributes: [
            :id, :job_id, :description, :print_location_id,
            :number_format, :name_format,
            :_destroy
          ]
        }
          .merge(tiered_line_item_attributes)
      ],
      imprints: [
        :print_location_id
      ],
    )
  end
end
