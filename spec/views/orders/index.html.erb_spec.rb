require 'spec_helper'

describe "orders/index.html.erb" do
  it 'displays all 3 orders' do
  	assign :orders, [
  		create(:order, name: 'first'),
  		create(:order, name: 'second'),
  		create(:order, name: 'third')
  	]
  	render
  	expect(rendered).to have_selector 'td', text: 'first'
  	expect(rendered).to have_selector 'td', text: 'second'
  	expect(rendered).to have_selector 'td', text: 'third'
	end

	it 'displays Order ID, Order contact info, sales status, and total' do
		assign :orders, [
			create(:order, 
				name: 'o name',
				firstname: 'o firstname',
				lastname: 'o lastname',
				email: 'o@email.com',
				sales_status: :pending,
				total: 9.50
			)
		]
		render
		expect(rendered).to have_selector 'td', text: 'o name'
		expect(rendered).to have_selector 'td', text: 'o firstname'
		expect(rendered).to have_selector 'td', text: 'o lastname'
		expect(rendered).to have_selector 'td', text: 'o@email.com'
		expect(rendered).to have_selector 'td', text: 'Pending'
		expect(rendered).to have_selector 'td', text: '$9.50'
	end
end
