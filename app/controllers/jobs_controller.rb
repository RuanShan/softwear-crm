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
    @job = Job.create((permitted_params[:job] || {}).merge(order_id: params[:order_id]))
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
    response = {
      result: @job.destroyed? ? 'success' : 'failure'
    }
    response[:error] = @job.errors.messages[:deletion_status] unless @job.destroyed?
    render json: response
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


  #def create_imprints
  #  print_location_ids = params[:ids].split '/'
  #  result = 'failure'
  #  errors = []
  #  print_location_ids.each do |plid|
  #    imprint = Imprint.new(job_id: params[:job_id])
  #    if imprint.save
  #      result = 'success'
  #    else
  #      errors << imprint.errors.messages
  #    end
  #  end
  #  render json: {
  #    result: result,
  #    errors: (errors.empty? ? nil : errors),
  #  }
  #end
#
#  #def update_imprint
#  #  imprint = Imprint.find params[:imprint_id]
#  #  imprint.print_location_id = params[:imprint][:print_location_id]
#  #  if imprint.save
#  #    render json: { result: 'success' }
#  #  else
#  #    render json: { result: 'failure', errors: imprint.errors.messages }
#  #  end
#  #end
#
#  #def destroy_imprints
#  #  imprint_ids = params[:ids].split '/'
#  #  imprint_ids.each do |impid|
#  #    Imprint.find(impid).destroy
#  #  end
#  #  render json: {
#  #    result: 'success'
#  #  }
  #end

  private
  def permitted_params
    params.permit(:order_id, :job_id, :ids, job: [
      :id, :name, :description, :collapsed
    ], imprint: [:print_location_id])
  end

end
