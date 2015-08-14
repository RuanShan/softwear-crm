module Api
  class ImprintableVariantsController < Softwear::Lib::ApiController
    def index
      params.permit(:imprintable, :color)
      if params[:imprintable] && params[:color]
        index_by imprintable: params[:imprintable], color: params[:color]
      else
        super do
          @imprintable_variant =
            ImprintableVariant.joins(:color, :size)
              .where(colors: { retail: true })
              .where(sizes: { retail: true })
        end
      end
    end

    def index_by(options)
      imprintable_name = options[:imprintable]
      color_name       = options[:color]

      imprintable = Imprintable.find_by(common_name: imprintable_name)

      return head 404 if imprintable.nil?

      @imprintable_variants =
        imprintable.variants_of_color(color_name)
        .where(sizes: { retail: true })


      respond_to do |format|
        format.json { render json: @imprintable_variants, include: includes }
      end
    end

    private

    def permitted_params
      [:weight]
    end

    def includes
      [:color, :size]
    end
  end
end
