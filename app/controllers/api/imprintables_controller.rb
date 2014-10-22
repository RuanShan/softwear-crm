module Api
  class ImprintablesController < ApiController
    def index
      super do
        @imprintables = Imprintable.where(retail: true)
      end
    end

    private

    def permitted_attributes
      [
        :common_name,
        :base_upcharge,  :xxl_upcharge,    :xxxl_upcharge,
        :xxxxl_upcharge, :xxxxxl_upcharge, :xxxxxxl_upcharge
      ]
    end
    
    def includes
      [:colors, :sizes, :imprintable_variants]
    end
  end
end
