class FbaJobTemplatesController < InheritedResources::Base
  def index
    @current_action = 'fba_job_templates#index'
    @fba_job_templates = FbaJobTemplate.page(params[:page])
  end

  def show
    super do |format|
      format.html { redirect_to action: :edit }
      format.js
    end
  end

  private

  def permitted_params
    params.permit(
      fba_job_template: [
        :name,
        print_location_ids: [],
        imprint_descriptions: []
      ]
    )
  end
end
