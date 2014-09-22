require 'spec_helper'

describe 'orders/edit.html.erb', order_spec: true do
  login_user

	let!(:order) { create(:order) }
	before(:each) { assign :order, order}

	it 'displays the order name and ID' do
    params[:id] = order.id
		render
		expect(rendered).to have_css 'h1', text: "Edit Order ##{order.id}"
		expect(rendered).to have_css 'small', text: order.name
	end

  it 'displays a "download names and numbers" button on the top right' do
    render
    expect(rendered).to have_css(
      "a[href='#{name_number_csv_from_order_path(order)}']",
      text: 'Names/Numbers CSV'
    )
  end
end
