require 'spec_helper'

describe ImprintDrop, liquid: true do
  subject { ImprintDrop.new(build(:valid_imprint) ) }
  let(:imprint) { create(valid_imprint) }
  it { is_expected.to respond_to(:description) }
  it { is_expected.to respond_to(:imprint_location) }
  it { is_expected.to respond_to(:imprint_method) }
end
