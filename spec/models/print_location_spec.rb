require 'spec_helper'

describe PrintLocation do

  it { is_expected.to be_paranoid }

  describe 'Relationships' do
    it { is_expected.to belong_to(:imprint_method) }
    it { is_expected.to have_many :imprints }
  end

  describe 'Validations' do
    it { is_expected.to validate_presence_of(:max_height) }
    it { is_expected.to validate_presence_of(:max_width) }
    it { is_expected.to validate_numericality_of (:max_height) }
    it { is_expected.to validate_numericality_of(:max_width) }
    it { is_expected.to validate_presence_of(:name) }
  end
end
