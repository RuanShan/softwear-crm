require 'spec_helper'

describe 'orders/edit.html.erb', order_spec: true do
  login_user

	let!(:order) { create(:order) }
	before(:each) { assign :order, order}

	it 'displays the order name and ID' do
    params[:id] = order.id
		render
		expect(rendered).to have_css 'h1', text: "Order ##{order.id}"
		expect(rendered).to have_css 'h2', text: order.name
	end

  it 'displays a "download names and numbers" button on the top right' do
    allow(order).to receive_message_chain(:imprints, :name_number).and_return [1]
    params[:id] = order.id
    render
    expect(rendered).to have_text('Name/Numbers')
  end
end
