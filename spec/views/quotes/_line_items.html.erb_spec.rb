require 'spec_helper'

describe 'quotes/_line_items.html.erb', quote_spec: true do
  before(:each) do
    render partial: 'quotes/line_items', locals: { quote: build_stubbed(:valid_quote) }
  end

  it 'displays an "add group" button' do
    expect(rendered).to have_css("form[action='#{line_item_groups_path}'][data-remote='true']")
    expect(rendered).to have_css("button[type='submit']")
  end
end