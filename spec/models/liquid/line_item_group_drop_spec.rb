require 'spec_helper'

describe LineItemGroupDrop, liquid: true do
  subject { LineItemGroupDrop.new(build(:line_item_group) ) }
  it { is_expected.to respond_to(:name) }
  it { is_expected.to respond_to(:description) }
  it { is_expected.to respond_to :line_items }
end