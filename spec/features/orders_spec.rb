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

    scenario 'A user can create an order from a quote', retry: 3 do
      select 'Paid in full on purchase', from: 'Payment terms'
      date_array = DateTime.current.to_s.split(/\W|T/)
      fill_in 'In Hand By Date', with:  "#{ (date_array[1].to_i + 1).to_s }/#{ date_array[2] }"\
                                        "/#{ date_array.first } 4:00 PM"
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
        date_array = DateTime.current.to_s.split(/\W|T/)
        fill_in 'In Hand By Date', with:  "#{ (date_array[1].to_i + 1).to_s }/#{ date_array[2] }"\
                                          "/#{ date_array.first } 4:00 PM"
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

  scenario 'A user can add a comment to an order', add_comment: true, story_842: true do
    visit edit_order_path order

    find('a', text: 'Comments').click

    fill_in 'Title', with: 'Test?'
    fill_in 'Comment', with: 'This is what I want to see'

    click_button 'Submit'

    expect(page).to have_content 'Test?'
    expect(page).to have_content 'This is what I want to see'

    order.reload
    expect(order.private_comments.where(title: 'Test?')).to exist
    expect(order.private_comments.where(comment: 'This is what I want to see')).to exist
  end

  scenario 'A user can remove a comment from an order', remove_comment: true, story_842: true do
    order.comments << Comment.create(title: 'Test Note?', comment: 'This is what I want to see', role: 'private')

    visit edit_order_path order

    find('a', text: 'Comments').click

    sleep 0.5
    sleep 1 if ci?
    first('.delete-comment').click
    sleep 0.5

    order.reload
    expect(order.comments.where(title: 'Test Note?')).to_not exist
    expect(order.comments.where(comment: 'This is what I want to see')).to_not exist
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

  scenario 'user edits an existing order', current: true do
    visit edit_order_path order
    wait_for_ajax
    click_link 'Details'
    wait_for_ajax

    fill_in 'Name', with: 'New Title'
    select 'approved', from: 'Invoice state'
    click_button 'Save'

    sleep 2
    expect(Order.where(name: 'New Title')).to exist
    expect(Order.where(invoice_state: 'approved')).to exist
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
    click_link 'Timeline'
    expect(page).to have_content "Updated order #{order.name}"
  end

  scenario 'user can access notification interface from orders index', story_913: true do
    # look for phone icon, make sure it links to notification form modal
    # look for thumbs up, make sure it links to picked up
  end

  scenario 'user can attempt to notify customer, and take note of what happened', story_913: true do 
    # go to order
    # click notify (phone icon)
    # get form, fill out
    # press submit, 
    # check page timeline for stuff
    # check order notification status 
  end

  scenario 'user can notify customer and update state', story_913: true do 
    # go to order
    # click notify (phone icon)
    # get form, fill out
    # press submit, 
    # check page timeline for stuff
    # check order notification status 
  end

  scenario 'user can mark order as picked up', story_913: true do 
    visit edit_order_path(order)
    click_link 'Picked Up'
    sleep(0.5)
    page.driver.browser.switch_to.alert.accept
    sleep(1)
    find("button[data-dismiss='modal']").click
    expect(page).to have_selector("#order_#{order.id} > .notification-state", text: 'Picked up')
  end

end
