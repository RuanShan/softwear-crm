module ApiControllerTests
  shared_examples 'api_controller' do
    resource_name = described_class.controller_name.singularize
    resource_type = described_class.controller_name.singularize.camelize

    describe 'GET #index' do
      context 'with params' do
        it 'queries based on permitted field names in the params' do
          allow(controller).to receive(:permitted_attributes)
            .and_return [:field_1]

          expect(Kernel.const_get(resource_type))
            .to receive(:where).with('field_1' => 'value_1')
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

end
