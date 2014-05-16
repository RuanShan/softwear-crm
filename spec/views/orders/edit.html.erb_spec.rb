require 'spec_helper'

describe 'orders/edit.html.erb', order_spec: true do
	let!(:order) {create(:order)}
	before :each do
		assign :order, order
	end

	it 'displays the order name and ID' do
		render
		expect(rendered).to have_css 'h1', text: "Edit Order ##{order.id}"
		expect(rendered).to have_css 'small', text: order.name
	end
end
