require 'spec_helper'

describe 'quotes/_line_items.html.erb', quote_spec: true do
  it 'displays an "add group" button', pending: 'Someone figure this out...' do
    params[:quote_id] = 0
    render partial: 'quotes/line_items', locals: { quote: build_stubbed(:valid_quote) }

    expect(rendered).to have_css("form[action='#{quote_line_item_groups_path}'][data-remote='true']")
    expect(rendered).to have_css("button[type='submit']")
  end
end
