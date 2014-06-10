require 'spec_helper'

describe ImprintablesController, imprintable_spec: true do
	let!(:valid_user) { create :alternate_user }
	before(:each) { sign_in valid_user }

  describe 'GET index' do
    let(:imprintable) { create(:valid_imprintable) }

    it 'assigns imprintables' do
      get :index
      expect(assigns(:imprintables)).to eq([imprintable])
    end
  end
end