module PricingModule
  def get_prices(imprintable, decoration_price)
    {
      base_price: (is_valid_price?(imprintable.base_price) ? imprintable.base_price + decoration_price : '--'),
      xxl_price: (is_valid_price?(imprintable.xxl_price) ? imprintable.xxl_price + decoration_price : '--'),
      xxxl_price: (is_valid_price?(imprintable.xxxl_price) ? imprintable.xxxl_price + decoration_price : '--'),
      xxxxl_price: (is_valid_price?(imprintable.xxxxl_price) ? imprintable.xxxxl_price + decoration_price : '--'),
      xxxxxl_price: (is_valid_price?(imprintable.xxxxxl_price) ? imprintable.xxxxxl_price + decoration_price : '--'),
      xxxxxxl_price: (is_valid_price?(imprintable.xxxxxxl_price) ? imprintable.xxxxxxl_price + decoration_price : '--')
    }
  end

  def is_valid_price?(number)
    (!number.nil?) && (number > 0)
  end
end
