require 'spec_helper'
include FormBuilderHelpers

describe 'LancengFormBuilder', helper_spec: true do
  let!(:object) { mock_model('DummyObject', name: 'test', do_it: true) }
  let!(:f) { test_form_for object, builder: LancengFormBuilder }

  it 'responds to text_field, text_area, select and submit' do
    expect(f.text_field :name).to include 'dummy_object[name]'
    expect(f.text_area :name).to include 'dummy_object[name]'
    f.select(:name, ['one', 'two', 'three']).tap do |it|
      expect(it).to include '<select'
      expect(it).to include 'one'
      expect(it).to include 'two'
      expect(it).to include 'three'
    end
    expect(f.submit).to include 'submit'
  end

  %i(text_field password_field
    text_area number_field check_box).each do |input_type|

    describe "##{input_type}" do
      it 'has the "form-control" class added' do
        expect(f.send(input_type, :name))
          .to match(/class\=\".*form\-control.*\"/)
      end
    end
  end

  it 'responds to custom form building methods' do
    f.check_box_with_text_field(:do_it, :name).tap do |it|
      expect(it).to include 'class="input-group"'
      expect(it).to include 'type="checkbox"'
      expect(it).to include '<textarea'
    end
    expect(f.datetime :name).to include 'datetime'
  end

  describe '#error_for' do

    context 'when the object has errors' do
      before do
        allow(object).to receive_message_chain(:errors, :full_messages_for)
          .and_return ['Test Error']
        allow(object).to receive_message_chain(:errors, :include?)
          .and_return true
      end

      it "displays the object's full error messages" do
        expect(f.error_for :name).to include 'Test Error'
      end
    end

    context 'when the object has no errors' do
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

  describe 'proxy methods' do
    describe '#label' do
      let(:standard_f) do
        test_form_for object
      end

      context 'when called without parameters' do
        it 'preceeds the content of another method call with a label' do
          expect(f.label.text_field(:name))
            .to eq f.label(:name) + f.text_field(:name)
        end
      end

      context 'when called with one string parameter' do
        it 'adds the second parameter to the label call' do
          expect(f.label('Hello').text_field(:name))
            .to eq f.label(:name, 'Hello') + f.text_field(:name)
        end
      end

      context 'when called normally' do
        it 'works the same as a standard form builder' do
          expect(f.label(:name, 'Cool')).to eq standard_f.label(:name, 'Cool')
        end
      end
    end

    describe '#error' do
      context 'when the record has errors' do
        before do
          allow(object).to receive_message_chain(:errors, :full_messages_for)
            .and_return ['Test Error']
          allow(object).to receive_message_chain(:errors, :include?)
            .and_return true
        end

        it 'preceeds the content of another method call with #error_for' do
          expect(f.error.text_field(:name))
            .to eq f.error_for(:name) + f.text_field(:name)
        end

        it 'can be chained with #label' do
          expect(f.label.error.text_field(:name)).to eq(
            f.label(:name) + f.error_for(:name) + f.text_field(:name)
          )
        end
      end

      context 'when the record has no errors' do
        it 'should not add anything to the result of the final method' do
          expect(f.error.text_field(:name)).to eq f.text_field(:name)
        end
      end
    end
  end
end