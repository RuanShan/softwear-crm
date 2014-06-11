require 'spec_helper'

describe '/line_items/_standard_edit_entry.html.erb', line_item_spec: true do
	let!(:line_item) { create :non_imprintable_line_item }
  before(:each) { render partial: '/line_items/standard_edit_entry', locals: {line_item: line_item} }

  it 'should render the fields in a div, parented by the form' do
  	within_form_for LineItem do
  		expect(rendered).to have_field_for :name, inside: 'div'
  		expect(rendered).to have_field_for :taxable, inside: 'div'
  		expect(rendered).to have_field_for :quantity, inside: 'div'
  		expect(rendered).to have_field_for :unit_price, inside: 'div'
  	end
    expect(rendered).to have_css 'form > div > input'
  end
end