require 'spec_helper'

describe 'orders/_table_entry.html.erb', order_spec: true do
  login_user

	before :each do
		render partial: 'orders/table_entry', locals: { order: create(:order,
    	name: 'o name',
			firstname: 'o firstname',
			lastname: 'o lastname',
			email: 'o@email.com',
			sales_status: 'Pending') }
	end

	it 'displays Order ID, Order contact info, sales status, and total' do
		expect(rendered).to have_selector 'td', text: 'o name'
		expect(rendered).to have_selector 'td', text: 'o firstname'
		expect(rendered).to have_selector 'td', text: 'o lastname'
		expect(rendered).to have_selector 'td', text: 'o@email.com'
		expect(rendered).to have_selector 'td', text: 'Pending'
		expect(rendered).to have_selector 'td', text: '$0.00'
	end
end