require 'spec_helper'
include ApplicationHelper

feature 'Order management', order_spec: true, js: true do
  given!(:order) { create(:order) }

  scenario 'user views the index of orders' do
    visit root_path
    unhide_dashboard
    click_link 'Orders'
    wait_for_ajax
    click_link 'List'
    expect(page).to have_css("tr#order_#{order.id}")
  end

  scenario 'user creates a new order' do
    visit root_path
    unhide_dashboard
    click_link 'Orders'
    wait_for_ajax
    click_link 'New'

    fill_in 'Email', with: 'test@example.com'
    fill_in 'Firstname', with: 'Guy'
    fill_in 'Lastname', with: 'Fieri'
    fill_in 'Phone number', with: '321-654-9870'
    fill_in 'Company', with: 'Probably Nothing'
    fill_in 'Twitter', with: 'stuff'

    click_button 'Next'
    wait_for_ajax

    fill_in 'Name', with: 'Whatever this should be'
    fill_in 'In Hand By Date', with: (Time.now + 1.month).to_s
    select 'Half down on purchase', from: 'Terms'

    click_button 'Next'
    wait_for_ajax

    select 'Pick up in Ypsilanti', from: 'Delivery method'
    # select 'In House Delivery', from: 'Shipping Method'

    click_button 'Submit'

    expect(Order.where(firstname: 'Guy')).to exist
  end

  scenario 'phone number field enforces proper format' do
    visit root_path
    unhide_dashboard
    click_link 'Orders'
    wait_for_ajax
    click_link 'New'

    phone_number_field = find_field('order[phone_number]')

    fill_in 'Phone number', with: '1236547895'
    wait_for_ajax
    expect(phone_number_field.value).to eq '123-654-7895'

    visit current_path

    fill_in 'Phone number', with: 'abc123'
    wait_for_ajax
    expect(phone_number_field.value).to eq '123-___-____'
  end

  scenario 'User edits an existing order', wip: false do
    visit orders_path
    find("a[title='Edit']").click
    wait_for_ajax
    click_link 'Details'
    wait_for_ajax
    
    sleep 120
  end
end
