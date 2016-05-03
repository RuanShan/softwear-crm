require 'spec_helper'
include FormBuilderHelpers

describe 'BatchFormBuilder', helper_spec: true do
  let!(:object) { mock_model('DummyObject', name: 'test', do_it: true, id: 2) }
  let!(:f) { test_form_for object, builder: BatchFormBuilder }

  let(:template) { f.instance_variable_get(:@template) }

  %i(text_field password_field
    text_area number_field check_box).each do |input_type|

    describe "##{input_type}" do
      it "should call #{input_type}_tag on the template" do
        expect(template).to receive("#{input_type}_tag")
        f.send(input_type, :name)
      end

      it 'should assign input names in the format of object[id][field]' do
        expect(f.send(input_type, :name))
          .to include 'name="dummy_object[2][name]"'
      end
    end
  end

  describe '#select' do
    it 'should not be implemented' do
      expect { f.select(:name) }.to raise_error
    end
  end
end
