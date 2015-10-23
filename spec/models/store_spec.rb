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
  end
end
