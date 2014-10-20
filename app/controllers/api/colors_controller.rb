module Api
  class ColorsController < ApiController
    def index
      super { @colors = Color.where(retail: true) }
    end

    protected

    def permitted_attributes
      [:name, :sku, :hexcode]
    end
  end
end