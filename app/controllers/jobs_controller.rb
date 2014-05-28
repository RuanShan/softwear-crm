class JobsController < InheritedResources::Base
  [:update, :destroy].each do |action|
    define_method action do
      send(action.to_s+'!') do |success, failure|
        success.json { render json: {result: 'success'} }
        failure.json do
          modal_html = "didn't work"
          with_format :html do
            modal_html = render_to_string(partial: 'shared/modal_errors', locals: { object: @job })
          end
          puts modal_html
          render json: {
            result: 'failure',
            errors: @job.errors.messages,
            modal: modal_html
          }
        end
      end
    end
  end

  def create
    new_job_name = 'New Job'
    name_counter = 0
    relevant_jobs = Job.where order_id: session[:order]
    while relevant_jobs.reject { |j| j.name != new_job_name }.count > 0
      new_job_name = "New Job #{name_counter}"
      name_counter += 1
    end
    @job = Job.new(permitted_params[:job].merge(name: new_job_name, order_id: session[:order]))
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

  def with_format(format)
    old_formats = formats
    self.formats = [format]
    yield
    self.formats = old_formats
    nil
  end

end
