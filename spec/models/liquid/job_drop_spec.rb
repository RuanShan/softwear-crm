require 'spec_helper'

describe JobDrop, liquid: true do
  subject { JobDrop.new(build(:job) ) }
  it { is_expected.to respond_to(:name) }
  it { is_expected.to respond_to(:description) }
  it { is_expected.to respond_to :line_items }
  it { is_expected.to respond_to :imprints }
  it { is_expected.to respond_to :imprintable_tiers }
  it { is_expected.to respond_to :additional_options_and_markups }
end
