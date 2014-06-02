module ImprintableHelper
  def find_brand(imprintable)
    if imprintable.style_id.present?
      brand = imprintable.style.brand
      brand.id
    else
      nil
    end
  end

  def find_variants(imprintable)
    variants = ImprintableVariant.find_by_sql("SELECT * FROM imprintable_variants AS iv
                                                  JOIN sizes
                                                  ON iv.size_id = sizes.id
                                                  WHERE imprintable_id = #{imprintable.id}
                                                  ORDER BY color_id, sort_order")
  end
end