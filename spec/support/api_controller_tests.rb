module ApiControllerTests
  shared_examples 'api_controller index' do
    resource_name = described_class.controller_name.singularize
    resource_type = described_class.controller_name.singularize.camelize

    describe 'GET #index', api_controller_spec: true do
      context 'with params' do
        it 'queries based on permitted field names in the params' do
          allow(Kernel.const_get(resource_type)).to receive(:column_names)
            .and_return ['field_1']

          expect(Kernel.const_get(resource_type))
            .to receive(:where).with(hash_including('field_1' => 'value_1'))
          expect(controller).to receive(:instance_variable_set)
            .with("@#{resource_name.pluralize}", anything)

          begin
            get :index, format: :json, field_1: 'value_1', bad_field: 'dumb_val'
          rescue ActiveRecord::StatementInvalid
          end
        end
      end
    end
  end

  shared_examples 'api_controller create' do
    resource_type = described_class.controller_name.singularize.camelize

    describe 'POST #create', api_controller_spec: true do
      it 'sets the "Location" header to the resource url' do
        allow(Kernel.const_get(resource_type))
          .to receive(:create).and_return mock_model(resource_type, id: 5)

        post :create, format: :json

        expect(response.headers.keys).to include 'Location'
        expect(response.headers['Location'])
          .to eq controller.send(:collection_url, 5)
      end
    end
  end
end
