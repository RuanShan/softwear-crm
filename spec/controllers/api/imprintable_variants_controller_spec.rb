require 'spec_helper'
include ApiControllerTests

describe Api::ImprintableVariantsController, api_imprintable_variant_spec: true, api_spec: true do
  let!(:valid_user) { create :alternate_user }
  before(:each) { sign_in valid_user }

  before(:each) do
    allow_any_instance_of(Api::ImprintableVariantsController)
      .to receive(:token_authenticate_user!)
      .and_return true
  end

  describe 'GET #index' do
    context 'with valid "color" and "imprintable" parameters' do
      let!(:imprintable) { create :valid_imprintable, common_name: 'Common' }

      it "returns imprintable_variants associated with the imprintable and color" do
        expect(Imprintable).to receive(:find_by).with(common_name: 'Common')
          .and_return imprintable

        dummy = double('variants')
        expect(dummy)
          .to receive(:where)
          .with(sizes: { retail: true })
          .and_return 'test'

        expect(imprintable)
          .to receive(:variants_of_color)
          .with('Blue')
          .and_return dummy

        get :index, format: :json, color: 'Blue', imprintable: 'Common'

        expect(assigns(:imprintable_variants)).to eq 'test'
      end
    end

    context 'with invalid "color" and "imprintable" parameters' do
      it 'returns 404' do
        get :index, format: :json, color: 'Blue', imprintable: 'Common'

        expect(response.code).to eq '404'
      end
    end
  end
end
