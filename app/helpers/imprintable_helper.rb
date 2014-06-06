module ImprintableHelper
  def find_brand(imprintable)
    if imprintable.style_id.present?
      brand = imprintable.style.brand
      brand.id
    else
      nil
    end
  end
end