module PricingModule
  def get_prices(imprintable, decoration_price)
    {
      base_price: (is_valid_price?(imprintable.base_price) ? (imprintable.base_price + decoration_price) : 'n/a'),
      xxl_price: (is_valid_price?(imprintable.xxl_price) ? (imprintable.xxl_price + decoration_price) : 'n/a'),
      xxxl_price: (is_valid_price?(imprintable.xxxl_price) ? (imprintable.xxxl_price + decoration_price) : 'n/a'),
      xxxxl_price: (is_valid_price?(imprintable.xxxxl_price) ? (imprintable.xxxxl_price + decoration_price) : 'n/a'),
      xxxxxl_price: (is_valid_price?(imprintable.xxxxxl_price) ? (imprintable.xxxxxl_price + decoration_price) : 'n/a'),
      xxxxxxl_price: (is_valid_price?(imprintable.xxxxxxl_price) ? (imprintable.xxxxxxl_price + decoration_price) : 'n/a')
    }
  end

  def is_valid_price?(number)
    (!number.nil?)
  end
end
