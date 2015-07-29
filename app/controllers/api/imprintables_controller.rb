module Api
  class ImprintablesController < ApiController
    include ActiveRecord::Sanitization::ClassMethods

    def index
      super do
        if (query = params.delete(:q))
          if query.is_a?(String)
            ids = Imprintable.search do
                fulltext query
                with :retail, true
              end
                .results.map(&:id)

            @imprintables = Imprintable.where(id: ids)
          else
            @imprintables = Imprintable.all
            query.each do |key, val|
              like = sanitize_sql_like(val.downcase).gsub("\\%", "%")
              @imprintables = @imprintables.where("LOWER(?) LIKE '#{like}'", key)
            end
          end
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
        :xxxxl_upcharge, :xxxxxl_upcharge, :xxxxxxl_upcharge,
        :default_photo_url, :photo_urls, :supplier_link, :brand_name,
        :coordinate_ids, :similar_imprintable_ids,
        :imprintable_category_names, :tag
      ]
    end

    def includes
      [
        :colors, :sizes,
        imprintable_variants: {
          include: {
            color: { only: [:name, :hexcode] },
            size: { only: [:name, :display_value, :sort_order] }
          }
        }
      ]
    end
  end
end
