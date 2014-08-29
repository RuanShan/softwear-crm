module Api
  class ImprintablesController < ApiController
    def index
      # @imprintables = Imprintable.where(standard_offering: true)
      super
    end

    def show
      @imprintable = Imprintable.find(params[:id])
      respond_to do |format|
        format.json { render json: @imprintable, include: [:colors, :sizes, :style, :brand, :imprintable_variants] }
      end
    end

    private

    def permitted_attributes
      [:common_name]
    end
  end
end
