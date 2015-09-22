require 'spec_helper'

describe 'orders/_table_entry.html.erb', order_spec: true do
  login_user

  before :each do
    render partial: 'orders/table_entry', locals: { order: create(:order,
      name: 'o name',
      firstname: 'o firstname',
      lastname: 'o lastname',
      email: 'o@email.com',
      terms: 'Payment Complete') }
  end

	it 'displays Order ID, Order contact info, payment_state, invoice_state, production_state,  and total' do
		expect(rendered).to have_selector 'td', text: 'o name'
		expect(rendered).to have_selector 'td', text: 'o firstname'
		expect(rendered).to have_selector 'td', text: 'o lastname'
		expect(rendered).to have_selector 'td', text: 'o@email.com'
		expect(rendered).to have_selector 'td.payment-state', text: 'Payment complete'
		expect(rendered).to have_selector 'td.production-state', text: 'Pending'
		expect(rendered).to have_selector 'td.invoice-state', text: 'Pending'
		expect(rendered).to have_selector 'td.notification-state', text: 'Pending'
		expect(rendered).to have_selector 'td', text: '$0.00'
	end
end
