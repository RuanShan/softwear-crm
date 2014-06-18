class ImprintsController < InheritedResources::Base
  [:create, :update, :destroy].each do |action|
    define_method action do
      send("#{action}!") do |success, failure|
        success.json do
          render json: { result: 'success', imprint_id: @imprint.id }
        end
        failure.json do
          render json: { result: 'failure', errors: @imprint.errors.messages }
        end
      end
    end
  end

  def new
    super do |format|
      format.html do
        render partial: 'orders/imprint', locals: { job: Job.find(params[:job_id]) }
      end
    end
  end

private
  def permitted_params
    params.permit(:job_id, :id, imprint: [ :print_location_id, :job_id ])
  end
end