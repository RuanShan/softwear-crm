require 'spec_helper'
include ApplicationHelper

feature 'Order management', order_spec: true, js: true do
  given!(:valid_user) { create(:user) }
  background(:each) { sign_in_as valid_user }

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
    fill_in 'In Hand By Date', with: '12/25/2025 12:00 AM'
    select User.find(order.salesperson_id).full_name, from: 'Salesperson'
    wait_for_ajax
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

  scenario 'an order with a line item that has a bad imprintable variant removes it and informs the user', retry: 4, bugfix: true do
    job = create(:job)
    line_item = create(:imprintable_line_item)
    job.line_items << line_item
    line_item.update_column :imprintable_object_id, 19999
    order.jobs << job

    visit edit_order_path order

    expect(page).to have_content "Some line items in this order were somehow referencing "\
                                 "imprintable variants that don't exist and were removed."

    expect(job.reload.line_items).to be_empty
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
      fill_in 'In Hand By Date', with: '12/25/2025 12:00 AM'
      sleep 0.5
      click_button 'Next'

      sleep 0.5
      select 'Pick up in Ann Arbor', from: 'Delivery method'
      sleep 0.5
      click_button 'Submit'
      expect(page).to have_content 'Order was successfully created.'
      expect(Order.where(firstname: quote.first_name)).to exist
    end

    context 'when failing to fill the order form properly' do
      scenario 'entries are still created in the linker table', retry: 5, stillcreated: true, story_248: true do
        expect(OrderQuote.count).to eq(0)
#       fail the form
        click_button 'Next'
        date_array = DateTime.current.to_s.split(/\W|T/)
        sleep 0.5
        click_button 'Submit'
#       expect failure
        expect(page).to have_content 'There was an error saving the order'
        close_error_modal
        click_button 'Next'

        fill_in 'In Hand By Date', with: '12/25/2025 12:00 AM'
        sleep 0.1
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

  scenario 'user edits an existing order', no_ci: true do
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

  scenario 'user can attempt to notify customer, and take note of what happened', story_913: true do
    PublicActivity.with_tracking do
      visit edit_order_path(order)
      find('.glyphicon-phone-alt').click
      sleep(0.5)
      select('Attempted', from: 'What did you do?')
      fill_in('And what are the details?',  with: 'Left Voicemail')
      click_button('Update Notification state')
      sleep(1)
      find("button[data-dismiss='modal']").click
      expect(page).to have_selector("#order_#{order.id} > .notification-state", text: 'Attempted')
      click_link "Timeline"
      sleep(0.3)
      expect(page).to have_content "changed order notification_state from pending to attempted via transition attempted with the details Left Voicemail"
    end
  end

  scenario 'user can notify customer and update state', story_913: true do
    PublicActivity.with_tracking do
      visit edit_order_path(order)
      find('.glyphicon-phone-alt').click
      sleep(0.5)
      select('Notified', from: 'What did you do?')
      fill_in('And what are the details?', with:  'Spoke over the phone')
      click_button('Update Notification state')
      sleep(1)
      find("button[data-dismiss='modal']").click
      expect(page).to have_selector("#order_#{order.id} > .notification-state", text: 'Notified')
      click_link "Timeline"
      sleep(0.3)
      expect(page).to have_content 'changed order notification_state from pending to notified via transition notified with the details Spoke over the phone'
    end
  end

  scenario 'user can mark order as picked up', story_913: true do
    visit edit_order_path(order)
      PublicActivity.with_tracking do
      find('.glyphicon-thumbs-up').click
      sleep(0.5)
      page.driver.browser.switch_to.alert.accept
      sleep(1)
      find("button[data-dismiss='modal']").click
      expect(page).to have_selector("#order_#{order.id} > .notification-state", text: 'Picked up')
    end
  end

  scenario 'a salesperson can see and click the customer portal link to the order', js: true do
    visit orders_path
    expect(page).to have_text(customer_order_path(order.customer_key))
    # Clicking that link opens a new tab which confuses capybara
  end


  context 'search', search: true, no_ci: true  do
    background do
      visit orders_path
    end

    scenario 'user can filter on invoice state', story_914: true do
      find("[id$=invoice_state]").select 'pending'
      click_button 'Search'

      expect(Sunspot.session).to be_a_search_for Order
      expect(Sunspot.session).to have_search_params(:with, :invoice_state, ['pending'])
    end

    scenario 'user can filter on payment status', story_914: true do
      find("[id$=payment_status]").select 'Payment Terms Met'
      click_button 'Search'

      expect(Sunspot.session).to be_a_search_for Order
      expect(Sunspot.session).to have_search_params(:with, :payment_status, ['Payment Terms Met'])
    end

    scenario 'user can filter on delivery deadline before', story_926: true do
      time = 5.days.ago

      find("[id$=in_hand_by][less_than=true]").click
      sleep 0.1
      find("[id$=in_hand_by][less_than=true]").set time.strftime('%m/%d/%Y %I:%M %p')
      find('.order-search-fulltext').click
      click_button 'Search'

      expect(Sunspot.session).to be_a_search_for Order
      expect(Sunspot.session).to have_search_params(:with) { with(:in_hand_by).less_than(time.to_date) }
    end
  end
end
