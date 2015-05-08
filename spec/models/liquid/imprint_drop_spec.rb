require 'spec_helper'

describe QuoteDrop, liquid: true do
  subject { QuoteDrop.new(build(:valid_quote) ) }
  it { is_expected.to respond_to(:imprint_method) }
  it { is_expected.to respond_to(:imprint_location) }
  it { is_expected.to respond_to(:description) }
end