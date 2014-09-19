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
    super do |format|
      format.html do
        render partial: 'imprints/imprint', 
               locals: { job: Job.find(params[:job_id]) }
      end

      format.js
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
    end
  end

  def update
    @job = Job.find(params[:job_id])

    batch_update(create_negatives: true,
                 parent: @job,
                 assignment: method(:assign_imprint_attributes)) do |format|
      format.js
    end
  end

  private

  def assign_imprint_attributes(imprint, attrs)
    name_number_attrs = attrs.delete('name_number')
    if name_number_attrs
      imprint.name_number_id ||= NameNumber.create.id
      imprint.name_number.update_attributes(name_number_attrs)
    end

    attrs.each do |key, value|
      imprint.send("#{key}=", value)
    end
  end

  def permitted_params
    params.permit(
      :job_id, :id,
      imprint: [
        :print_location_id, :job_id, :has_name_number,
        name_number: [:name, :number]
      ]
    )
  end
end
