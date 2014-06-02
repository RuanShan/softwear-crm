require 'spec_helper'

describe 'orders/_line_item_new.html.erb', line_item_spec: true do
	before(:each) { render partial: 'order/line_item_new', locals: {line_item: LineItem.new} }

  it 'should display a yes/no checkbox' do
    expect(rendered).to have_selector 'input[type="radio"][value="0"]'
    expect(rendered).to have_selector 'input[type="radio"][value="1"]'
  end

  it 'should have a cancel button' do
  	expect(rendered).to have_selector 'button', text: 'Cancel'
  end
end