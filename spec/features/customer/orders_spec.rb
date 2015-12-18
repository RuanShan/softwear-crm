require 'spec_helper'
include ApplicationHelper

feature 'Customer Order Management', order_spec: true, js: true do

  given!(:order) { create(:order) }

  scenario 'A customer provided the link to the order can view the order' do
    visit customer_order_path(order.customer_key)
    expect(page).to have_text("Invoice ##{order.id}")
  end

end
