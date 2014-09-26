require 'spec_helper'

describe LineItemGroup, line_item_group_spec: true, story_66: true do
  it { is_expected.to be_paranoid }

  describe 'Relationships' do
    it { is_expected.to have_many(:line_items) }
    it { is_expected.to belong_to(:quote) }
  end
end