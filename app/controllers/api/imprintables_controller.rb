module Api
  class ImprintablesController < ApiController
    def index
      super do
        if params[:q]
          query = params[:q]
          ids = Imprintable.search do
              fulltext query
              with :retail, true
            end
              .results.map(&:id)

          @imprintables = Imprintable.where(id: ids)
        else
          @imprintables = Imprintable.where(retail: true)
        end
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
      # [:colors, :sizes, :imprintable_variants]
    end
  end
end
