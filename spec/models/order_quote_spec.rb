require 'spec_helper'

describe OrderQuote, order_spec: true, quote_spec: true, story_48: true do
  it { is_expected.to be_paranoid }

  describe 'Relationships' do
    it { is_expected.to belong_to(:order) }
    it { is_expected.to belong_to(:quote) }
  end
end
