require 'spec_helper'

describe LineItemDrop, liquid: true do
  subject { LineItemDrop.new(build(:line_item) ) }
  it { is_expected.to respond_to(:name) }
  it { is_expected.to respond_to(:description) }
  it { is_expected.to respond_to :quantity }
  it { is_expected.to respond_to :unit_price }
  it { is_expected.to respond_to :url }
  it { is_expected.to respond_to :taxable }
end