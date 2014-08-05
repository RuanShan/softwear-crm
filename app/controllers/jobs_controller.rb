class JobsController < InheritedResources::Base
  belongs_to :order, shallow: true
  respond_to :json

  def update
    super do |success, failure|
      success.json { render json: { result: 'success' } }
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
    end
  end

  def create
    super do |success, failure|
      success.html do
        render partial: 'orders/job', locals: { job: @job, animated: true }
      end

      failure.json do
        render json: {
          result: 'failure',
          errors: @job.errors.full_messages
        }
      end
    end
  end

  def destroy
    super do |format|
      format.json do
        render json: {
          result: @job.destroyed? ? 'success' : 'failure',
          error: @job.destroyed? ? @job.errors.messages[:deletion_status] : nil
        }
      end
    end
  end

  def show
    super do |format|
      format.html do
        redirect_to order_path(@job.order, anchor: "jobs-#{@job.id}")
      end
      format.json do
        render json: {
          result: 'success',
          content: render_string(partial: 'orders/job', locals: {job: @job})
        }
      end
    end
  end

  private

  def permitted_params
    params.permit(
        :order_id, :job_id, :ids,

        job:     [:id, :name, :description, :collapsed], 
        imprint: [:print_location_id]
    )
  end
end
