module Api
  class ImprintablesController < Softwear::Lib::ApiController
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
          @imprintables = Imprintable
            .includes(imprintable_variants: [:color, :size])
            .where(retail: true)
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
        :imprintable_category_names, :tag, :marketplace_name,
        :sizing_chart_url,

        :water_resistance_level, :sleeve_type, :sleeve_length, :neck_style,
        :neck_size, :fabric_type, :is_stain_resistant, :fit_type, :fabric_wash,
        :department_name, :chest_size, :package_height, :package_width,
        :package_length
      ]
    end

    def includes
      if params[:detail_level].to_s == 'low'
        [ ]
      elsif params[:detail_level].to_s == 'medium'
        [
            :colors, :sizes
        ]
      elsif params[:detail_level].to_s == 'high'
        [
            :colors, :sizes, imprintable_variants: {
            methods: [:sku]
          }
        ]
      else
        [
            :colors, :sizes,
            imprintable_variants: {
                methods: [:sku],
                include: {
                    color: { only: [:name, :hexcode, :map] },
                    size: { only: [:name, :display_value, :sort_order] }
                }
            }
        ]
      end
    end
  end
end
