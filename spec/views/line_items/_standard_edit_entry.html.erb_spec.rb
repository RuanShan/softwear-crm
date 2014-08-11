require 'spec_helper'

describe '/line_items/_standard_edit_entry.html.erb', line_item_spec: true do
	let!(:line_item) { create :non_imprintable_line_item }
  before(:each) { render partial: '/line_items/standard_edit_entry', locals: {line_item: line_item} }

  # TODO use it { is_expected.to } syntax for all of these expectations
  it 'should render input fields for name, description, taxable, quantity, and unit_price, all with the line_item id in the name' do
		expect(rendered).to have_css "*[name='line_item[#{line_item.id}[name]]']"
    expect(rendered).to have_css "*[name='line_item[#{line_item.id}[description]]']"
		expect(rendered).to have_css "*[name='line_item[#{line_item.id}[taxable]]']"
		expect(rendered).to have_css "*[name='line_item[#{line_item.id}[quantity]]']"
		expect(rendered).to have_css "*[name='line_item[#{line_item.id}[unit_price]]']"
  end
end