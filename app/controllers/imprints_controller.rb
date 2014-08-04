class ImprintsController < InheritedResources::Base
  %i(create update destroy).each do |action|
    define_method action do
      send("#{action}!") do |success, failure|
        success.json { render json: { result: 'success', imprint_id: @imprint.id } }
        failure.json { render json: { result: 'failure', errors: @imprint.errors.messages } }
      end
    end
  end

  def new
    super do |format|
      format.html { render partial: 'orders/imprint', locals: { job: Job.find(params[:job_id]) } }
    end
  end

  def show
    super do |format|
      format.html { redirect_to order_path(@imprint.order, anchor: "jobs-#{@imprint.job.id}-imprint-#{@imprint.id}") }
    end
  end

  private

  def permitted_params
    params.permit(:job_id, :id, imprint: [ :print_location_id, :job_id ])
  end
end
