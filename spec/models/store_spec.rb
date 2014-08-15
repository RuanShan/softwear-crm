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
  end
end
