require 'spec_helper'

describe ImprintMethod, imprint_method_spec: true do

  describe 'Validations' do
    it { should validate_presence_of(:name) }
    it { should validate_uniqueness_of(:name) }
  end

  describe 'Relationships' do
    it { should have_many(:ink_colors) }
    it { should have_many(:print_locations) }
    it { should accept_nested_attributes_for(:ink_colors) }
    it { should accept_nested_attributes_for(:print_locations) }
  end

end