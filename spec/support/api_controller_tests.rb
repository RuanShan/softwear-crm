module ApiControllerTests
  shared_examples 'api_controller index' do
    resource_name = described_class.controller_name.singularize
    resource_type_name = described_class.controller_name.singularize.camelize
    resource_type = Kernel.const_get(resource_type_name)

    describe 'GET #index', api_controller_spec: true do
      context 'with params' do
        it 'queries based on permitted field names in the params' do
          allow_any_instance_of(described_class)
            .to receive(:permitted_attributes)
            .and_return [:field_1]

          begin
            get :index, format: :json, field_1: 'value_1', bad_field: 'dumb_val'
          rescue ActiveRecord::StatementInvalid => e
            expect(e.message).to match /Unknown column .+field_1/
          end
        end
      end
    end
  end

  shared_examples 'api_controller create' do
    resource_type = described_class.controller_name.singularize.camelize

    describe 'POST #create', api_controller_spec: true do
      it 'sets the "Location" header to the resource url' do
        allow_any_instance_of(described_class).to receive(:record)
          .and_return double('record', id: 5)

        dummy_success = double('success')
        allow(dummy_success).to receive(:json) { |&block|
          block.call
        }
        dummy_failure = double('failure')
        allow(dummy_failure).to receive(:json)

        allow_any_instance_of(described_class).to receive(:create!) { |&block|
          block.call dummy_success, dummy_failure
        }

        post :create, format: :json

        expect(response.headers.keys).to include 'Location'
        expect(response.headers['Location'])
          .to eq controller.send(:resource_url, 5)
      end
    end
  end
end
