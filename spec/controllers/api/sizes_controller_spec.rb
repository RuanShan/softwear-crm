require 'spec_helper'
include ApiControllerTests

describe Api::SizesController, api_size_spec: true, api_spec: true do
  it_behaves_like 'api_controller index'
  it_behaves_like 'api_controller create'

  describe 'GET #index' do
    context 'with "color" and "imprintable" parameters' do
      it "returns sizes associated with the imprintable's variant by color" do
        allow(Imprintable).to receive(:find_by).with('Common')
        allow(Color).to receive(:find_by )#....

        get :index, format: :json, color: 'Blue', imprintable: 'Common'
      end
    end
  end
end
