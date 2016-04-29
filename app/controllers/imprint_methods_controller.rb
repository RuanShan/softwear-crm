class ImprintMethodsController < InheritedResources::Base
  before_filter :sales_manager_only, only: [:create, :update, :destroy, :edit]
  before_action :set_current_action

  def show
    super do |format|
      format.html { redirect_to edit_imprint_method_path params[:id] }
      format.js { render layout: nil,
                         locals: { imprint_method: ImprintMethod.find(params[:id]) } }
    end
  end

  def update
    super do |success, failure|
      success.html { redirect_to imprint_methods_path }
      failure.html { render :edit }
    end
  end

  def print_locations
    @imprint_method = ImprintMethod.find params[:imprint_method_id]
    @print_locations = @imprint_method.print_locations

    render partial: 'print_locations_select',
           locals: { print_locations: @print_locations, name: params[:name] }
  end

  protected

  def set_current_action
    @current_action = 'imprint_methods'
  end

  private

  def permitted_params
    params.permit(
      :name,
      ink_color_names: [],
      imprint_method: [
        :name, :name_number,
        ink_color_names: [],
        print_locations_attributes: [
          :name, :max_height, :max_width, :imprint_method_id, :id,
          :ideal_width, :ideal_height, :platen_hoop_id, :popularity,
          :_destroy,
        ],
        option_types_attributes: [
          :id, :name, :_destroy,
          option_values_attributes: [
            :id, :value, :_destroy,
          ]
        ]
      ]
    )
  end
end
