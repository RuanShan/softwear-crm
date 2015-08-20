require 'spec_helper'

describe InkColor do

  it { is_expected.to be_paranoid }

  describe 'Validations' do
    it { is_expected.to validate_presence_of :name }
  end

  describe 'Relationships' do
    it { is_expected.to have_many :imprint_method_ink_colors }
    it { is_expected.to have_many :artwork_request_ink_colors }
  end
end
