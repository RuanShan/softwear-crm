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

  it 'has a link to "Order Report"  on the top right' do
    render
    expect(rendered).to have_link('Order Report')
  end

  it 'displays the jobs tab by default' do 
    render
    expect(rendered).to have_css("li.active", text: 'Jobs')
    expect(rendered).to have_css("#jobs.active")  
  end

end
