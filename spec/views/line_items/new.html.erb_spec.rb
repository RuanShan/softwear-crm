require 'spec_helper'

describe 'line_items/new.html.erb', line_item_spec: true do
	before(:each) do
		assign(:line_item, LineItem.new)
	  render template: 'line_items/new', locals: {job: create(:job)} 
	end

  it 'should display a yes/no checkbox' do
    expect(rendered).to have_selector 'input[type="radio"][value="no"]'
    expect(rendered).to have_selector 'input[type="radio"][value="yes"]'
  end

  it 'should have a cancel button' do
  	expect(rendered).to have_selector 'button', text: 'Cancel'
  end
end