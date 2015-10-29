module Api
  class ColorsController < Softwear::Lib::ApiController
    def index
      super { @colors = Color.where(retail: true) }
    end

    protected

    def permitted_attributes
      [:name, :sku, :hexcode, :map]
    end
  end
end
