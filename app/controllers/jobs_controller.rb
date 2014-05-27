class JobsController < InheritedResources::Base
  [:update, :destroy].each do |action|
    define_method action do
      send(action.to_s+'!') do |success, failure|
        success.json { render json: {result: 'success'} }
        failure.json do
          render json: {
            result: 'failure',
            errors: @job.errors.messages
          }
        end
      end
    end
  end

  def create
    @job = Job.new(permitted_params[:job].merge(order_id: session[:order]))
    @job.save
    if @job.valid?
      render partial: 'orders/job', locals: { job: @job, animated: true }
    else
      render json: {
        result: 'failure',
        errors: @job.errors.messages
      }
    end
  end

  private
  def permitted_params
    params.permit(job: [
      :name, :description
    ])
  end

end
