require 'spec_helper'

describe SampleLocation, sample_location_spec: true do

  describe 'Relationships' do
    it { is_expected.to belong_to(:imprintable) }
    it { is_expected.to belong_to(:store) }
  end
end
