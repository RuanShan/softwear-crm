require 'spec_helper'

describe 'LancengFormBuilder', helper_spec: true do
  let!(:object) { mock_model('DummyObject', name: 'test', do_it: true) }

  it 'can create a dummy form builder' do
    expect(LancengFormBuilder.dummy_for object).to be_a LancengFormBuilder
  end

  context 'given a dummy builder' do
    let!(:f) { LancengFormBuilder.dummy_for object }

    it 'responds to the usual form builder methods' do
      expect(f.text_field :name).to_not be_nil
      expect(f.text_area :name).to_not be_nil
      expect(f.select :name, ['one', 'two', 'three']).to_not be_nil
      expect(f.submit).to_not be_nil
    end

    it 'responds to custom form building methods' do
      expect(f.check_box_with_text_field :do_it, :name).to_not be_nil
      expect(f.datetime :name).to_not be_nil
    end

    it 'the error_for method only adds content if there is an error' do
      expect(f.error_for :name).to be_nil

      errors_stub = Class.new Hash do
        def full_messages_for(method)
          if self[method] then return [self[method]] end
        end
      end.new
      object.stub(:errors) { errors_stub }
      object.errors[:name] = 'test error'

      expect(f.error_for :name).to_not be_nil
    end
  end
end