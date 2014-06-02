require 'spec_helper'

describe 'orders/_line_item_new.html.erb' do
  it 'should display a yes/no checkbox' do
    render partial: 'order/line_item_new', locals: {line_item: LineItem.new}
    expect(rendered).to have_selector 'input[type="radio"][value="0"]'
    expect(rendered).to have_selector 'input[type="radio"][value="1"]'
  end
end