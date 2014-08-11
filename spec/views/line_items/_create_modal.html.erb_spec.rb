require 'spec_helper'

describe 'line_items/_create_modal.html.erb', line_item_spec: true do
  before(:each) do
    assign(:line_itemable, create(:job))
    assign(:line_item, LineItem.new)
  end

  it 'should display a yes/no checkbox' do
    render
    expect(rendered).to have_selector 'input[type="radio"][value="no"]'
    expect(rendered).to have_selector 'input[type="radio"][value="yes"]'
  end

  it 'should have a cancel button' do
    render
    expect(rendered).to have_selector 'a', text: 'Cancel'
  end
end