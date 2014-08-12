require 'spec_helper'

describe Search::Filter, search_spec: true do
  it { is_expected.to belong_to :filter_holder }
  it { is_expected.to belong_to :filter_type }

  it { is_expected.to validate_presence_of :filter_type }

  it 'delegates methods to its filter type' do
    subject = create :number_filter
    type = subject.filter_type
    expect(type).to receive(:apply)
    Order.search do
      subject.apply(self)
    end
  end

  it 'destroys its type when destroyed' do
    subject = create :number_filter
    type_id = subject.filter_type.id
    expect(Search::NumberFilter.where id: type_id).to exist
    subject.destroy
    expect(Search::NumberFilter.where id: type_id).to_not exist
  end

  describe '.new' do
    it 'allows a new filter to be created with a certain type' do
      expect(Search::Filter.new(Search::NumberFilter).filter_type).to be_a Search::NumberFilter
    end

    it 'passes remaining params to the filter type, rather than the filter' do
      subject = Search::Filter.new(Search::StringFilter, value: 'test')
      expect(subject.type.value).to eq 'test'
    end
  end
end