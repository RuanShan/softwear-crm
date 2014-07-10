require 'spec_helper'
include ApplicationHelper

describe PricesController, js: true, prices_spec: true do
  let!(:valid_user) { create :alternate_user }
  before(:each) { sign_in valid_user }
  let!(:imprintable) { create(:valid_imprintable) }
  describe 'POST create' do
    it 'assigns @imprintable and @prices_hash' do
      post :create, { decoration_price: 4, id: imprintable.id, format: 'js' }
      expect(assigns(:imprintable)).to eq(imprintable)
      expect(assigns(:prices_hash)).to eq({ base_price: BigDecimal.new(imprintable.base_price+4),
                                            xxl_price: BigDecimal.new(imprintable.xxl_price+4),
                                            xxxl_price: BigDecimal.new(imprintable.xxxl_price+4),
                                            xxxxl_price: BigDecimal.new(imprintable.xxxxl_price+4),
                                            xxxxxl_price: BigDecimal.new(imprintable.xxxxxl_price+4),
                                            xxxxxxl_price: '--' })
    end
  end

  describe 'GET new' do
    it 'assigns @imprintable' do
      get :new, { id: imprintable.id, format: 'js' }
      expect(assigns(:imprintable)).to eq(imprintable)
    end
  end
end
