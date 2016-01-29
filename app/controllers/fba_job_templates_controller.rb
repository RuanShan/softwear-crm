class FbaJobTemplatesController < InheritedResources::Base
  include ActionView::Helpers::FormOptionsHelper

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

  def create
    super do |success, failure|
      success.html { redirect_to action: :index }
      failure.html { render }
    end
  end

  def print_locations
    return if params[:imprint_method_id].blank?

    @print_location_id_options = PrintLocation.where(imprint_method_id: params[:imprint_method_id])
      .map { |pl| { id: pl.id, text: pl.name } }.to_json
  end

  private

  def permitted_params
    params.permit(
      fba_job_template: [
        :name,
        fba_imprint_templates_attributes: [
          :print_location_id, :description, :artwork_id,
          :id, :_destroy
        ],
        mockup_attributes: [
          :file, :id
        ]
      ]
    )
  end
end
