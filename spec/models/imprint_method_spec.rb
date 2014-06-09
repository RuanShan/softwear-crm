require 'spec_helper'

describe ImprintMethod do 

  describe 'Validations' do
    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:production_name) }
    it { should validate_uniqueness_of(:production_name).scoped_to :name}
  end

  describe 'Relationships' do
    it { should have_many(:ink_colors) }
    it { should have_many(:print_locations) }
    it { should accept_nested_attributes_for(:ink_colors) }
    it { should accept_nested_attributes_for(:print_locations) }
  end

end