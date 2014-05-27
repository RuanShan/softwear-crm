class JobsController < InheritedResources::Base
  [:create, :update, :destroy].each do |action|
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

  private
  def permitted_params
    params.permit(job: [
      :name, :description
    ])
  end

end
