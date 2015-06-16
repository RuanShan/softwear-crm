require 'spec_helper'

describe ImprintableTierDrop, liquid: true do
  subject { ImprintableTierDrop.new(number: 3, name: 'Good' ) }
  it { is_expected.to respond_to(:name) }
  it { is_expected.to respond_to(:line_items) }
end
