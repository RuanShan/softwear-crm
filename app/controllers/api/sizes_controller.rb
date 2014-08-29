module Api
  class SizesController < ApiController
    def index
      params.permit(:imprintable, :color)
      if params[:imprintable] && params[:color]
        index_by imprintable: params[:imprintable], color: params[:color]
      else
        super
      end
    end

    private

    def index_by(options)
      imprintable_name = options[:imprintable]
      color_name       = options[:color]
      
      imprintable = Imprintable.find_by(common_name: imprintable_name)

      return head 404 if imprintable.nil?
      
      @sizes = imprintable.sizes_by_color color_name

      respond_to do |format|
        format.json { render json: @sizes }
      end
    end
  end
end