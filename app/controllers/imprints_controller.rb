class ImprintsController < InheritedResources::Base
  include BatchUpdate

  belongs_to :job, shallow: true

  %i(create destroy).each do |action|
    define_method action do
      send("#{action}!") do |success, failure|
        success.json do
          render json: { result: 'success', imprint_id: @imprint.id }
        end

        failure.json do
          render json: { result: 'failure', errors: @imprint.errors.messages }
        end
        success.js
        failure.js
      end
    end
  end

  def new
    if params[:job_id].nil?
      respond_to do |format|
        format.js
      end
    else
      super do |format|
        format.html do
          render partial: 'imprints/imprint', 
                 locals: { job: Job.find(params[:job_id]) }
        end

        format.js
      end
    end
  end

  def show
    super do |format|
      format.html do
        redirect_to order_path(
          @imprint.order,
          anchor: "jobs-#{@imprint.job.id}-imprint-#{@imprint.id}"
        )
      end
      format.js
    end
  end

  def update
    @job = Job.find(params[:job_id])

    batch_update(
      create_negatives: true,
      parent:           @job,
      assignment:       method(:assign_imprint_attributes)
    ) do |format|
      format.js
    end
  end

private

  def assign_imprint_attributes(imprint, attrs)
    attrs.each do |key, value|
      imprint.send("#{key}=", value)
    end
  end

  def permitted_params
    params.permit(
      :job_id, :id,
      :select_tag_name, :description_name,
      imprint: [
        :print_location_id, :job_id, :has_name_number,
        :name_format, :number_format,
        name_number: [:name, :number]
      ]
    )
  end
end
