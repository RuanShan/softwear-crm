class NameNumbersController < InheritedResources::Base
  actions :create, :destroy
  respond_to :js

  def create
    @job = Job.find(params[:job_id])
    super do |success, failure|
      success.js
      failure.js do
        @error = "Errors: #{@name_number.errors.full_messages.join(', ')}"
      end
    end
  end

  def destroy
    @job = Job.find(params[:job_id])
    super do |format|
      format.js
    end
  end

private

  def permitted_params
    params.permit(name_number: [:name, :number, :imprintable_variant_id, :imprint_id])
  end
end
