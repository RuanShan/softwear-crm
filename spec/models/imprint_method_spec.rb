require 'spec_helper'

describe ImprintMethod, imprint_methods_spec: true do

  it { is_expected.to be_paranoid }

  describe 'Relationships' do
    it { is_expected.to have_many(:ink_colors) }
    it { is_expected.to have_many(:print_locations) }
    it { is_expected.to have_and_belong_to_many(:imprintables) }
    it { is_expected.to accept_nested_attributes_for(:ink_colors) }
    it { is_expected.to accept_nested_attributes_for(:print_locations) }
  end
  
  describe 'Validations' do
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_uniqueness_of(:name) }
  end
end
