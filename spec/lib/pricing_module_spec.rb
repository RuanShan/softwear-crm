require 'spec_helper'

describe PricingModule, prices_spec: true do
  include PricingModule

  class DummyClass
  end

  before(:all) do
    @dummy = DummyClass.new
    @dummy.extend PricingModule
  end

  describe 'get_prices' do
    let!(:imprintable) { create(:valid_imprintable) }
    it 'should return a hash with the imprintable prices + decoration_price' do
      decoration_price = 5
      resultant = {
                    base_price: BigDecimal.new(imprintable.base_price + 5),
                    xxl_price: BigDecimal.new(imprintable.xxl_price + 5),
                    xxxl_price: BigDecimal.new(imprintable.xxxl_price + 5),
                    xxxxl_price: BigDecimal.new(imprintable.xxxxl_price + 5),
                    xxxxxl_price: BigDecimal.new(imprintable.xxxxxl_price + 5),
                    xxxxxxl_price: 'n/a'
                  }
      expect(get_prices(imprintable, decoration_price)).to eq(resultant)
    end
  end
end
