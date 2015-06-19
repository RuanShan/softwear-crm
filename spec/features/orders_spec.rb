require 'spec_helper'
include ApplicationHelper

feature 'Order management', order_spec: true,  js: true do
  given!(:valid_user) { create(:user) }
  background(:each) { login_as valid_user }

  given!(:order) { create(:order) }

  scenario 'user views the index of orders' do
    visit root_path
    unhide_dashboard
    click_link 'Orders'
    wait_for_ajax
    click_link 'List'
    expect(page).to have_css("tr#order_#{order.id}")
  end

  scenario 'A user can create a new order' do
    visit root_path
    unhide_dashboard
    click_link 'Orders'
    wait_for_ajax
    click_link 'New'

    fill_in 'Email', with: 'test@example.com'
    fill_in 'Phone number', with: '321-654-9870'
    fill_in 'First name', with: 'Guy'
    fill_in 'Last name', with: 'Fieri'
    fill_in 'Company', with: 'Probably Nothing'
    fill_in 'Twitter', with: 'stuff'

    click_button 'Next'
    wait_for_ajax

    fill_in 'Name', with: 'Whatever this should be'
    date_array = DateTime.current.to_s.split(/\W|T/)
    in_hand_by = "#{ (date_array[1].to_i + 1).to_s }/#{ date_array[2] }"\
                 "/#{ date_array.first } 4:00 PM"
    fill_in 'In Hand By Date', with: in_hand_by
    select User.find(order.salesperson_id).full_name, from: 'Salesperson'
    sleep 15
    select order.store.name, from: 'Store'
    select 'Half down on purchase', from: 'Payment terms'

    click_button 'Next'
    wait_for_ajax

    select 'Pick up in Ypsilanti', from: 'Delivery method'

    sleep 1
    click_button 'Submit'
    sleep 1

    expect(Order.where(firstname: 'Guy')).to exist
  end

  context 'involving quotes' do
    given!(:quote) { create(:valid_quote) }
    background(:each) do
      visit edit_quote_path quote.id
      click_link 'Create Order from Quote'
      click_button 'Next'
    end

    scenario 'A user can create an order from a quote' do
      select 'Paid in full on purchase', from: 'Payment terms'
      click_button 'Next'

      select 'Pick up in Ann Arbor', from: 'Delivery method'
      click_button 'Submit'
      expect(page).to have_content 'Order was successfully created.'
      expect(Order.where(firstname: quote.first_name)).to exist
    end

    context 'when failing to fill the order form properly' do
      scenario 'entries are still created in the linker table', story_248: true do
        expect(OrderQuote.count).to eq(0)
#       fail the form
        click_button 'Next'
        sleep 0.5
        click_button 'Submit'
#       expect failure
        expect(page).to have_content 'There was an error saving the order'
        close_error_modal
        click_button 'Next'

        select 'Net 30', from: 'order_terms'
        click_button 'Next'

        select 'Pick up in Ann Arbor', from: 'order_delivery_method'
        click_button 'Submit'
        expect(page).to have_content 'Order was successfully created.'
        expect(OrderQuote.count).to eq(1)
      end
    end
  end

  scenario 'user sees an error message when submitting invalid information' do
    visit root_path
    unhide_dashboard
    click_link 'Orders'
    sleep 1
    click_link 'New'

    fill_in 'Email', with: 'nope'

    2.times { click_button 'Next'; sleep 1 }
    click_button 'Submit'

    sleep 1
    expect(page).to have_content 'Email is not a valid email address'
  end

  scenario 'user edits an existing order' do
    visit edit_order_path order
    wait_for_ajax
    click_link 'Details'
    wait_for_ajax

    fill_in 'Name', with: 'New Title'

    click_button 'Save'

    expect(Order.where(name: 'New Title')).to exist
  end

  scenario 'when editing, submitting invalid information displays error content' do
    visit edit_order_path(order, anchor: 'details')
    fill_in 'Email', with: 'bad email!'
    click_button 'Save'

    expect(page).to have_content 'Email is not a valid email address'
  end

  scenario 'user can view updates on the timeline', timeline_spec: true do
    PublicActivity.with_tracking do
      order.firstname = 'Newfirst'
      order.save
    end
    visit edit_order_path(order)

    expect(page).to have_content "Updated order #{order.name}"
  end
end
