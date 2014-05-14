require 'spec_helper'

describe ImprintablesController do

  describe 'GET index' do
    let(:imprintable) { create(:valid_imprintable) }

    it 'assigns imprintables' do
      get :index
      expect(assigns(:imprintables)).to eq([imprintable])
    end
  end
end