class JobsController < InheritedResources::Base
  def update
    super do |success, failure|
      success.json { render json: {result: 'success'} }
      failure.json do
        modal_html = 'ERROR'
        with_format :html do
          modal_html = render_to_string(partial: 'shared/modal_errors', locals: { object: @job })
        end
        render json: {
          result: 'failure',
          errors: @job.errors.messages,
          modal: modal_html
        }
      end
    end
  end

  def create
    # TODO move job name generation to model
    new_job_name = 'New Job'
    name_counter = 2
    relevant_jobs = Job.where order_id: params[:order_id]
    while relevant_jobs.reject { |j| j.name != new_job_name }.count > 0
      new_job_name = "New Job #{name_counter}"
      name_counter += 1
    end
    @job = Job.new(permitted_params[:job].merge(name: new_job_name, order_id: params[:order_id]))
    @job.save
    if @job.valid?
      render partial: 'orders/job', locals: { job: @job, animated: true }
    else
      render json: {
        result: 'failure',
        errors: @job.errors.full_messages
      }
    end
  end

  def destroy
    @job = Job.find params[:id]
    @job.destroy
    render json: {
      result: @job.destroyed? ? 'success' : 'failure'
    }
  end

  def show
    super do |format|
      format.html do
        render partial: 'orders/job', locals: { job: @job }
      end
    end
  end

  private
  def permitted_params
    params.permit(job: [
      :id, :name, :description
    ])
  end

end
