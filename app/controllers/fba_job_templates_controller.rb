class FbaJobTemplatesController < InheritedResources::Base
  include ActionView::Helpers::FormOptionsHelper

  def index
    @current_action = 'fba_job_templates#index'
    session[:fjt_needs_proof]   = params[:needs_proof]   if params[:needs_proof]
    session[:fjt_needs_artwork] = params[:needs_artwork] if params[:needs_artwork]

    art = filter_needs_artwork?
    proof = filter_needs_proof?
    if art || proof
      @fba_job_templates = FbaJobTemplate.search do
        if art && proof
          all_of do
            with :needs_artwork, true
            with :needs_proof,   true
          end
        elsif art
          with :needs_artwork, true
        elsif proof
          with :needs_proof,   true
        end

        paginate page: params[:page] || 1
      end
        .results
    else
      @fba_job_templates = FbaJobTemplate.page(params[:page])
    end
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

    @print_location_id_options = PrintLocation
      .where(imprint_method_id: params[:imprint_method_id])
      .map { |pl| { id: pl.id, text: pl.name } }
      .to_json
  end

  private

  def filter_needs_artwork?
    session[:fjt_needs_artwork] == '1'
  end
  def filter_needs_proof?
    session[:fjt_needs_proof] == '1'
  end

  def permitted_params
    params.permit(
      fba_job_template: [
        :name, :job_name,
        fba_imprint_templates_attributes: [
          :print_location_id, :description, :artwork_id,
          :id, :_destroy
        ],
        mockup_attributes: [
          :file, :id, :_destroy
        ]
      ]
    )
  end
end
