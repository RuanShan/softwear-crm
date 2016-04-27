require 'spec_helper'
include ApplicationHelper

feature 'Order management', slow: true, order_spec: true, js: true do
  given!(:valid_user) { create(:user) }
  given(:sales_manager) { create(:user, first_name: 'Sales', last_name: 'Man') }
  background(:each) { sign_in_as valid_user }

  given!(:order) { create(:order) }
  given!(:job) { create(:job, jobbable_id: order.id) }
  given!(:line_item) { create(:imprintable_line_item) }
  given!(:payment1) { create(:valid_payment, order: order) }
  given!(:payment2) { create(:valid_payment, order: order) }

  scenario 'user views the index of orders' do
    visit root_path
    unhide_dashboard
    click_link 'Orders'
    wait_for_ajax
    click_link 'List'
    expect(page).to have_css("tr#order_#{order.id}")
  end

  context 'Order Report' do
    before(:each) do
      order.jobs << job
      order.jobs.first.line_items << line_item
    end
    
    scenario 'a user can view the total counts on the top of the order report' do
      visit edit_order_path(order)
      sleep 1
      click_link "Production"
      sleep 1
      click_link "Order Report"
      sleep 1
      expect(page).to have_css("strong", text: "#{LineItem::get_total_pieces(order)}")
    end
  end

  context 'Imprintable Sheets' do
   
    before(:each) do
      order.jobs << job
      order.jobs.first.line_items << line_item
    end
    
    scenario 'A user can view only imprintable order sheets' do
      visit edit_order_path(order)
      sleep 1
      click_link "Production"
      sleep 1
      click_link "Imprintable Order Sheets"
      sleep 1
      expect(page).to have_content("Ordered By:")
      expect(page).to_not have_content("Inventoried By:")
    end

    scenario 'A user can view only imprintable receiving sheets' do
      visit edit_order_path(order)
      sleep 1
      click_link "Production"
      sleep 1
      click_link "Imprintable Receiving Sheets"
      sleep 1
      expect(page).to_not have_content("Ordered By:")
      expect(page).to have_content("Inventoried By:")
    end

    scenario 'A user can view both imprintable order/receiving sheets' do
      visit orders_path
      sleep 2
      find("a[title='Imprintable Sheets']").click
      sleep 1
      expect(page).to have_content("Ordered By:")
      expect(page).to have_content("Inventoried By:")
    end
  end

  scenario 'A user can create a new order', new: true do
    visit root_path
    unhide_dashboard
    click_link 'Orders'
    wait_for_ajax
    click_link 'New'

    fill_in 'Email', with: 'test@example.com'
    fill_in 'Phone number', with: '321-654-9870'
    fill_in 'Phone number extension', with: '28'
    fill_in 'First name', with: 'Guy'
    fill_in 'Last name', with: 'Fieri'
    fill_in 'Company', with: 'Probably Nothing'
    fill_in 'Twitter', with: 'stuff'

    click_button 'Next'
    wait_for_ajax

    fill_in 'Name', with: 'Whatever this should be'
    #fill_in 'In Hand By Date', with: '12/25/2025 12:00 AM'
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

    #asserts that the in_hand_by date is defaulted by today at 5pm.
    order = Order.find_by(firstname: 'Guy')
    expect(value_time(order.in_hand_by)).to eq(value_time(now_at_5))
  end

  scenario 'A user can specify sales tax as a percentage', new: true, tax_rate: true do
    visit root_path
    unhide_dashboard
    click_link 'Orders'
    wait_for_ajax
    click_link 'New'

    fill_in 'Email', with: 'test@example.com'
    fill_in 'Phone number', with: '321-654-9870'
    fill_in 'Phone number extension', with: '28'
    fill_in 'First name', with: 'Guy'
    fill_in 'Last name', with: 'Fieri'
    fill_in 'Company', with: 'Probably Nothing'
    fill_in 'Twitter', with: 'stuff'

    click_button 'Next'
    wait_for_ajax

    fill_in 'Name', with: 'Whatever this should be'
    #fill_in 'In Hand By Date', with: '12/25/2025 12:00 AM'
    select User.find(order.salesperson_id).full_name, from: 'Salesperson'
    wait_for_ajax
    select order.store.name, from: 'Store'
    select 'Half down on purchase', from: 'Payment terms'
    sleep 0.5
    fill_in "Tax rate", with: '7.5'
    sleep 1

    click_button 'Next'
    sleep 1

    select 'Pick up in Ypsilanti', from: 'Delivery method'

    sleep 1
    click_button 'Submit'
    sleep 1

    expect(Order.where(firstname: 'Guy')).to exist
    expect(Order.find_by(firstname: 'Guy').tax_rate).to eq 0.075
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
        _date_array = DateTime.current.to_s.split(/\W|T/)
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

  scenario 'salesperson can print individual receipts from payments tab' do
    visit edit_order_path order

    wait_for_ajax
    click_link 'Payments'
    wait_for_ajax

    expect(page).to have_link "show_#{payment1.id}"
    expect(page).to have_link "show_#{payment2.id}"

    click_link "show_#{payment1.id}"
    wait_for_ajax

    expect(page).to have_link "Return To Order"
    expect(page).to have_link "Print"
    expect(page).to have_text "Payment Receipt ##{payment1.id}"

    click_link 'Return To Order'
    wait_for_ajax

    click_link "show_#{payment2.id}"
    wait_for_ajax

    expect(page).to have_text "Payment Receipt ##{payment2.id}"
  end

  scenario 'user edits an existing order', no_ci: true do
    visit edit_order_path order
    wait_for_ajax
    click_link 'Details'
    wait_for_ajax

    fill_in 'Name', with: 'New Title'
    select 'approved', from: 'Invoice state'
    fill_in 'Phone number extension', with: '28'
    click_button 'Save'

    sleep 2
    expect(Order.where(name: 'New Title')).to exist
    expect(Order.where(invoice_state: 'approved')).to exist
    expect(Order.where(phone_number_extension: '28')).to exist
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
      click_link 'Sales'
      click_link 'Notify Customer'
      sleep(0.5)
      select('Attempted', from: 'What did you do?')
      fill_in('And what are the details?',  with: 'Left Voicemail')
      click_button('Update Notification state')
      sleep(1)
      find("button[data-dismiss='modal']").click
      expect(page).to have_selector("#order_#{order.id}_states .notification-state", text: 'Attempted')
      click_link "Timeline"
      sleep(0.3)
      expect(page).to have_content "changed order notification_state from pending to attempted via transition attempted with the details Left Voicemail"
    end
  end

  scenario 'user can notify customer and update state', story_913: true do
    PublicActivity.with_tracking do
      visit edit_order_path(order)
      click_link 'Sales'
      click_link 'Notify Customer'
      sleep(0.5)
      select('Notified', from: 'What did you do?')
      fill_in('And what are the details?', with:  'Spoke over the phone')
      click_button('Update Notification state')
      sleep(1)
      find("button[data-dismiss='modal']").click
      expect(page).to have_selector("#order_#{order.id}_states .notification-state", text: 'Notified')
      click_link "Timeline"
      sleep(0.3)
      expect(page).to have_content 'changed order notification_state from pending to notified via transition notified with the details Spoke over the phone'
    end
  end

  scenario 'user can mark order as picked up', story_913: true do
    visit edit_order_path(order)
    PublicActivity.with_tracking do
      click_link 'Sales'
      click_link 'Mark Picked Up'
      sleep(0.5)
      page.driver.browser.switch_to.alert.accept
      sleep(1)
      find("button[data-dismiss='modal']").click
      expect(page).to have_selector("#order_#{order.id}_states .notification-state", text: 'Picked up')
    end
  end

  scenario 'a salesperson can see and click the customer portal link to the order', js: true do
    visit orders_path
    expect(page).to have_text(customer_order_path(order.customer_key))
    # Clicking that link opens a new tab which confuses capybara
  end

  context 'cancelation', cancel: true do
    context 'without the sales_manager role' do
      background do
        allow(valid_user).to receive(:role?).and_return false
        allow(User).to receive(:of_role) { |*r| [(sales_manager if r.map(&:to_s).include?('sales_manager'))].compact }
      end

      scenario 'a user can see the list of sales managers when canceling the order (but cannot cancel it)' do
        expect(order).to be_valid
        visit edit_order_path(order)

        click_link 'Sales'
        find("#order_cancel").click
        sleep 1.5

        expect(page).to have_content "If you really need this order canceled, ask a sales manager:"
        expect(page).to have_content sales_manager.full_name
      end
    end

    context 'with the sales_manager role' do
      given(:quote) { create(:valid_quote, orders: [order]) }

      background do
        allow(valid_user).to receive(:role?) { |*r| r.map(&:to_s).include?('sales_manager') }
      end

      context 'when no cancelation criteria is met' do
        scenario 'a sales manager can see what tasks need to be performed' do
          visit edit_order_path(order)

          click_link 'Sales'
          find("#order_cancel").click
          sleep 1.5

          expect(page).to have_content "A salesperson cost must be filled out"
          expect(page).to have_content "An artist cost must be filled out"
          expect(page).to have_content "The order must have at least one private comment"
        end
      end

      context 'when there is a comment and a sales/artist cost' do
        background do
          order.private_comments.create!(title: "We suck", comment: "love to waste moni")
          order.costs.create!(type: 'Salesperson', amount: 5.00, time: 10.00)
          order.costs.create!(type: 'Artist', amount: 5.00, time: 10.00)
        end

        scenario 'a sales manager can cancel the order' do
          visit edit_order_path(order)

          click_link 'Sales'
          find("#order_cancel").click
          sleep 1.5

          expect(page).to have_content "ready to be canceled"
          expect(page).to have_content "Are you sure"

          click_button "Cancel Order"
          sleep 2

          expect(order.reload).to be_canceled
        end

        scenario 'canceling the order sets all order states to canceled' do
          visit edit_order_path(order)

          click_link 'Sales'
          find("#order_cancel").click
          sleep 1.5
          click_button "Cancel Order"
          sleep 2

          order.reload
          expect(order.invoice_state).to eq 'canceled'
          expect(order.production_state).to eq 'canceled'
          expect(order.payment_state).to eq 'Canceled'
          expect(order.artwork_state).to eq 'artwork_canceled'
          expect(order.notification_state).to eq 'notification_canceled'
        end

        scenario 'canceling the order also cancels its production order' do
          prod_order = create(:production_order, softwear_crm_id: order.id)
          order.update_column :softwear_prod_id, prod_order.id
          expect_any_instance_of(Production::Order).to receive(:canceled=).with(true)

          visit edit_order_path(order)

          click_link 'Sales'
          find("#order_cancel").click
          sleep 1.5
          click_button "Cancel Order"
          sleep 1
        end

        scenario 'canceling the order "loses" its quotes' do
          quote
          visit edit_order_path(order)

          click_link 'Sales'
          find("#order_cancel").click
          sleep 1.5
          click_button "Cancel Order"
          sleep 2

          expect(quote.reload.state).to eq("lost")
        end
      end
    end
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

    scenario 'user can search by order id' do
      fill_in "Search Terms", with: "#{order.id}"
      sleep 1
      click_button "Search"

      expect(Sunspot.session).to be_a_search_for Order
      expect(Sunspot.session).to have_search_params(:fulltext, "#{order.id}")
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
