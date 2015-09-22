require 'spec_helper'

describe "orders/index.html.erb", order_spec: true do

  login_user

  it 'displays all 3 orders' do
  	assign :orders, Kaminari.paginate_array([
  		create(:order, name: 'first'),
  		create(:order, name: 'second'),
  		create(:order, name: 'third')
  	]).page(1)
  	render
  	expect(rendered).to have_selector 'td', text: 'first'
  	expect(rendered).to have_selector 'td', text: 'second'
  	expect(rendered).to have_selector 'td', text: 'third'
  end

  it 'has a column for payment_state, invoice_state, notification_state' do 
    assign :orders, Kaminari.paginate_array([create(:order)]).page(1)
    render
    expect(rendered).to have_selector 'th', text: 'Payment'
    expect(rendered).to have_selector 'th', text: 'Invoice'
    expect(rendered).to have_selector 'th', text: 'Production'
    expect(rendered).to have_selector 'th', text: 'Notification'
  end

end
