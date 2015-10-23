require 'spec_helper'

describe Store, store_spec: true do
  it { is_expected.to be_paranoid }

  describe 'Relationships' do
    it { is_expected.to have_many(:sample_locations) }
    it { is_expected.to have_many(:imprintable_stores) }
    it { is_expected.to have_many(:imprintables).through(:imprintable_stores) }
  end

  describe 'Validations' do
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_presence_of(:address_1) }
    it { is_expected.to validate_presence_of(:city) }
    it { is_expected.to validate_presence_of(:state) }
    it { is_expected.to validate_presence_of(:zipcode) }
    it { is_expected.to validate_presence_of(:country) }
    it { is_expected.to validate_presence_of(:phone) }
    it { is_expected.to validate_presence_of(:sales_email) }
    it { is_expected.to validate_uniqueness_of(:name) }
  end

  describe '#address_array' do 
    let(:store) { build(:valid_store) }

    it 'returns an array of all the address fields' do 
      expect(store.address_array).to eq(
        [store.address_1, store.address_2, "#{store.city}, #{store.state} #{store.zipcode}", store.country].reject(&:blank?) 
      )
    end
  end

end
