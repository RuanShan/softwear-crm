require 'spec_helper'
include FormBuilderHelpers
# load Rails.root + 'lib/util/search_exception.rb'

describe 'SearchFormBuilder', search_spec: true do
  let!(:object) { mock_model('DummyObject', name: 'test', do_it: true) }

  let(:dummy_object_class) { object.class }
  
  let!(:f) do
    test_form_for object, builder: SearchFormBuilder do |_name, object, buffer|
      [object.class, nil, buffer]
    end
  end
  
  let(:template) { f.instance_variable_get(:@template) }
  
  let(:query) do
    build_stubbed(:search_query).tap do |query|
      allow(query)
        .to receive_message_chain(:query_models, :where, :first)
        .and_return double('Query Model', default_fulltext: 'test fulltext')
    end
  end

  let(:search_hash) do
    ReasonableHash.new(
      dummy_object: {
        '1' => { lastname: 'Johnson' },
        '2' => { commission_amount: 200 },
        fulltext: 'test'
      }
    )
  end

  before :each do
    allow(object.class).to receive(:searchable?).and_return true
  end

  describe '#pass_locals_to_controller' do
    it 'should render a hidden field for each hash element' do
      expect(template).to receive(:hidden_field_tag)
        .with('locals[test_1]', 'first')
        .and_call_original
      expect(template).to receive(:hidden_field_tag)
        .with('locals[test_2]', 'second')
        .and_call_original

      f.pass_locals_to_controller(test_1: 'first', test_2: 'second')
    end
  end

  [:filter_all, :filter_any].each do |method_name|
    describe "##{method_name}" do
      it "isn't implemented yet and raises an error" do
        expect{f.send(method_name) {}}.to raise_error SearchException
      end
    end
  end

  [:text_field, :text_area, :number_field].each do |method_name|
    describe "##{method_name}" do
      context 'without a model' do
        before :each do
          allow(f.instance_variable_get(:@model)).to receive(:nil?)
            .and_return true
        end

        it 'raises an error' do
          expect{f.send(method_name, :name)}
            .to raise_error SearchException
        end
      end

      it "sends #{method_name}_tag to the template with proper name format" do
        expect(template).to receive("#{method_name}_tag")
          .with('search[dummy_object[1[name]]]', anything, anything)

        f.send(method_name, :name)
      end
    end
  end

  describe '#label' do
    it 'calls label_tag with name formatted as search[model[num[field]]]' do
      expect(template).to receive(:label_tag)
        .with('search[dummy_object[1[name]]]', 'Name', {})

      f.label(:name)
    end

    # it { is_expected.to be_html_safe }
  end

  describe '#fulltext' do
    context 'no options' do
      it 'calls text_field_tag with name as search[model[fulltext]]' do
        expect(template).to receive(:text_field_tag)
          .with('search[dummy_object[fulltext]]', anything, anything)

        f.fulltext
      end
    end

    context 'textarea: true' do
      it 'calls text_area_tag with name as search[model[fulltext]]' do
        expect(template).to receive(:text_area_tag)
          .with('search[dummy_object[fulltext]]', anything, anything)
          
        f.fulltext textarea: true
      end
    end

    describe 'initial value' do
      context 'with a query' do
        before :each do
          f.instance_variable_set(:@query, query)
        end

        it "should be equal to the query's default_fulltext" do
          expect(f.fulltext).to include %(value="test fulltext")
        end
      end

      context 'with a valid last_search hash' do
        before :each do
          f.instance_variable_set(:@last_search, search_hash)
        end

        it 'should be equal to its fulltext' do
          expect(f.fulltext).to include %(value="test")
        end
      end

      context 'with a valid last_search index' do
        before :each do
          f.instance_variable_set(:@last_search, 1)
          allow(Search::Query).to receive(:find).and_return query
        end

        it "should be equal to the associated query's default_fulltext" do
          expect(f.fulltext).to include %(value="test fulltext")
        end
      end
    end
  end

  describe '#select', select: true do
    let(:options) { ['this', 'that', 'the other thing'] }

    it 'renders option tags for each given select option' do
      result = f.select(:name, options)
      
      options.each do |option|
        expect(result)
          .to include %(<option value="#{option}">#{option}</option>)
      end
    end

    context 'with an initial value' do
      before :each do
        allow(f).to receive(:initial_value_for).with(:name).and_return 'that'
      end

      it 'appoints the option of that value as default' do
        result = f.select(:name, options)

        expect(result).to include '<option selected="selected" value="that">'
      end
    end

    context 'display: :reverse' do
      it 'applies the #reverse method on the options for their display' do
        result = f.select(:name, options, display: :reverse)

        expect(result).to include '<option value="this">siht</option>'
      end
    end

    context 'when the option items respond to #id' do
      before :each do
        options.each do |o|
          allow(o).to receive(:id).and_return 'test_id'
        end
      end

      it 'sets the input values of the options to "classname#id"' do
        result = f.select(:name, options)

        options.each do |option|
          expect(result)
            .to include %(<option value="String#test_id">#{option}</option>)
        end
      end
    end
  end

  describe '#yes_or_no', yes_or_no: true do
    it 'should render 3 radio buttons with values "Yes", "No", and "Either"' do
      result = f.yes_or_no(:do_it)

      {true: 'Yes', false: 'No', nil: 'Either'}.each do |value, display|
        expect(result)
          .to include %(type="radio" value="#{value}" /><span>#{display}</span>)
      end
    end

    it 'formats the name of the radio buttons properly' do
      expect(f.yes_or_no(:do_it)).to include 'search[dummy_object[1[do_it]]]'
    end

    context 'yes: "Totally", no: "Doubtedly"' do
      it 'replaces the display of true and false with Totally and Doubtedly' do
        result = f.yes_or_no(:do_it, yes: 'Totally', no: 'Doubtedly')

        {true: 'Totally', false: 'Doubtedly'}.each do |value, display|
          expect(result)
            .to include %(value="#{value}" /><span>#{display}</span>)
        end
      end
    end
  end

  describe '#check_box' do
    it 'renders a hidden field and a check box' do
      expect(template).to receive(:hidden_field_tag).and_call_original
      expect(template).to receive(:check_box_tag).and_call_original

      f.check_box(:do_it)
    end
  end

  describe '#submit' do
    context 'with a query' do
      before :each do
        f.instance_variable_set(:@query, query)
      end

      it 'renders a submit_tag displaying "Save"' do
        expect(template).to receive(:submit_tag).with('Save', anything)
          .and_call_original
        expect(f.submit).to include 'Save'
      end
    end

    context 'without a query' do
      it 'renders a submit_tag displaying "Search"' do
        expect(template).to receive(:submit_tag).with('Search', anything)
          .and_call_original
        expect(f.submit).to include 'Search'
      end
    end

    it 'should be aliased as #search' do
      expect(f.search).to eq f.submit
    end
  end

  describe '#save' do
    it 'adds the fields and required for saving a query' do
      expect(template).to receive(:hidden_field_tag)
        .with('query[name]', '', anything)
        .and_call_original
      expect(template).to receive(:hidden_field_tag)
        .with('query[user_id]', anything, anything)
        .and_call_original
      expect(template).to receive(:hidden_field_tag)
        .with('target_path', '', anything)
        .and_call_original
      expect(template).to receive(:button_tag)
        .with('Save', anything)
        .and_call_original

      f.save
    end

    it 'assigns the btn-search-save class to the save button' do
      expect(f.save).to match(/\<button.+class\=\".*btn\-search\-save.*\"/)
    end
  end

  describe '@field_count' do
    %i(text_field text_area number_field 
       select yes_or_no check_box).each do |method_name|
      
      it "should be incremented by ##{method_name}" do
        before = f.instance_variable_get(:@field_count)
        if method_name == :select
          f.send(method_name, :name, [])
        else
          f.send(method_name, :name)
        end
        after  = f.instance_variable_get(:@field_count)

        expect(after - before).to eq 1
      end
    end
  end
end