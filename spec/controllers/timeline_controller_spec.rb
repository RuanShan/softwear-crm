require 'spec_helper'

describe TimelineController do
  let!(:order) { create(:order) }

  describe 'GET show' do

    context 'order_id is valid' do

      it 'assigns order, renders application layout' do
        get :show, { order_id: order.to_param }
        expect(assigns(:order)).to eq(order)
        expect(response).to render_template('layouts/application')
      end

    end

    context 'order_id is invalid' do
      it 'redirects to root and flashes error' do
        get :show, { order_id: 'crap'} do
          expect(response).to redirect_to root_path
          expect( flash[:error] ).to_not be_nil
        end
      end
    end
  end

  describe 'XHR GET show' do

    context 'order_id is valid' do
      it 'assigns order, renders no layout' do
        xhr :get, :show, { order_id: order.to_param }
        expect(assigns(:order)).to eq(order)
        expect(response).to render_template('timeline/show')
        expect(response).to_not render_template('layouts/application')
      end
    end

    context 'order_id is invalid' do
      it 'redirects to root and flashes error' do
        xhr :get, :show, { order_id: 'crap' }
        expect(response.status).to eq(404)
      end
    end
  end
end
