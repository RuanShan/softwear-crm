require 'spec_helper'

describe '_line_items.html.erb', line_item_group_spec: true, story_66: true do
  before(:each) do
    render partial: 'line_item_groups/line_items', locals: { line_item_group: build_stubbed(:line_item_group) }
  end

  it 'displays "add" and "update" line item buttons' do
    expect(rendered).to have_css('a',      text: 'Add Line Item')
    expect(rendered).to have_css('button', text: 'Update Line Items')
  end

  it 'displays a "delete group" button' do
    expect(rendered).to have_css('button', text: 'Delete Group')
  end
end
