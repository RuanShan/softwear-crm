require 'spec_helper'
include ApplicationHelper
require 'email_spec'

feature 'Quotes management', quote_spec: true, js: true do
  given!(:valid_user) { create(:alternate_user) }
  background(:each) { login_as(valid_user) }

  given!(:quote) { create(:valid_quote) }
  given!(:imprintable) { create(:valid_imprintable) }

  scenario 'A user can see a list of quotes' do
    visit root_path
    unhide_dashboard
    click_link 'quotes_list'
    click_link 'quotes_path_link'
    expect(page).to have_selector('.box-info')
    expect(current_path).to eq(quotes_path)
  end

  scenario 'A user can create a quote' do
    visit root_path
    unhide_dashboard

    click_link 'quotes_list'
    click_link 'new_quote_link'
    expect(current_path).to eq(new_quote_path)

    fill_in 'Email', with: 'test@spec.com'
    fill_in 'First Name', with: 'Capy'
    fill_in 'Last Name', with: 'Bara'
    click_button 'Next'
    sleep 0.5

    fill_in 'Quote Name', with: 'Quote Name'
    fill_in 'Valid Until Date', with: Time.now + 1.day
    fill_in 'Estimated Delivery Date', with: Time.now + 1.day
    click_button 'Next'
    sleep 0.5

    click_link 'Add Line Item'
    fill_in 'Name', with: 'Line Item Name'
    fill_in 'Description', with: 'Line Item Description'
    fill_in 'Quantity', with: 2
    fill_in 'Unit Price', with: 15
    click_button 'Submit'

    wait_for_ajax
    expect(page).to have_selector '.modal-content-success', text: 'Quote was successfully created.'
    expect(current_path). to eq(quote_path(quote.id + 1))
  end

  scenario 'A user can visit the edit quote page' do
    visit quotes_path
    find('i.fa.fa-edit').click
    expect(current_path).to eq(edit_quote_path quote.id)
  end

  scenario 'A user can edit a quote' do
    visit edit_quote_path quote.id
    find('a', text: 'Details').click
    fill_in 'Quote Name', with: 'New Quote Name'
    click_button 'Save'

    expect(current_path).to eq(quote_path quote.id)
    expect(quote.reload.name).to eq('New Quote Name')
  end

  feature 'Quote emailing' do
    scenario 'A user can email a quote to the customer' do
      visit edit_quote_path quote.id
      find('a[href="#actions"]').click
      click_link 'Email Quote'
      sleep 0.5
      find('input[value="Submit"]').click
      sleep 0.5

      expect(page).to have_selector '.modal-content-success'
      expect(current_path).to eq(edit_quote_path quote.id)
    end

    feature 'email recipients enforces proper formatting' do
      scenario 'no email is sent with improper formatting' do
        visit edit_quote_path quote.id
        find('a[href="#actions"]').click
        click_link 'Email Quote'
        sleep 0.5
        fill_in 'email_recipients', with: 'this.is.not@formatted.properly.com'
        find('input[value="Submit"]').click
        sleep 0.5

        expect(page).to_not have_selector '.modal-content-success'
        expect(page).to have_content 'Send Quote'
      end
    end
  end

  scenario 'A user can generate a quote from an imprintable pricing dialog', retry: 3 do
    visit imprintables_path
    decoration_price = 3.75
    find('i.fa.fa-dollar').click
    sleep 0.5
    find(:css, "input#decoration_price").set(decoration_price)
    click_button 'Fetch Prices!'

    click_link 'Create Quote from Table'
    fill_in 'Email', with: 'something@somethingelse.com'
    fill_in 'First Name', with: 'Capy'
    fill_in 'Last Name', with: 'Bara'
    click_button 'Next'
    sleep 0.5

    fill_in 'Valid Until Date', with: Time.now + 1.day
    fill_in 'Estimated Delivery Date', with: Time.now + 1.day
    click_button 'Next'
    sleep 0.5

    expect(page).to have_css("input[value='#{ imprintable.name }']")
    expect(page).to have_css("input[value='#{ imprintable.base_price + decoration_price }']")
    fill_in 'Description', with: 'Description'
    fill_in 'Quantity', with: '1'
    click_button 'Submit'

    expect(page).to have_selector '.modal-content-success', text: 'Quote was successfully created.'
    expect(current_path).to eq(quote_path(quote.id + 1))
  end

  scenario 'A user can add a single price from the pricing table to an existing quote', retry: 2 do
    visit imprintables_path
    find("#pricing_button_#{imprintable.id}").click
    find(:css, 'input#decoration_price').set(3.95)
    click_button 'Fetch Prices!'
    sleep 0.5
    click_link 'Add to Quote'
    sleep 0.5
    page.select(quote.name, from: 'quote_id')
    sleep 0.5
    click_button 'Submit'

    sleep 1
    expect(current_path).to eq(edit_quote_path quote.id)
    find('a[href="#line_items"]').click
    expect(page).to have_content(imprintable.name)
  end

  scenario 'Inputting bad data for a line item doesn\'t remove all line items' do
    visit new_quote_path
    fill_in 'Email', with: 'test@testing.com'
    fill_in 'First Name', with: 'Capy'
    fill_in 'Last Name', with: 'Bara'
    click_button 'Next'
    sleep 0.5

    fill_in 'Quote Name', with: 'Quote Name'
    fill_in 'Valid Until Date', with: Time.now + 1.day
    fill_in 'Estimated Delivery Date', with: Time.now + 1.day
    click_button 'Next'
    sleep 0.5

    click_link 'Add Line Item'
    fill_in 'Name', with: 'This Should Still be here!'
    fill_in 'Description', with: 'Line Item Description'
    fill_in 'Quantity', with: 2
    fill_in 'Unit Price', with: 15

    click_link 'Add Line Item'
    click_button 'Submit'
    close_error_modal
    click_button 'Next'
    click_button 'Next'
    expect(page).to have_selector('div.line-item-form', count: 2)
  end

  feature 'the following actions are tracked:' do
    scenario 'Quote creation' do
      visit root_path
      unhide_dashboard
      click_link 'quotes_list'
      click_link 'new_quote_link'
      expect(current_path).to eq(new_quote_path)

      fill_in 'Email', with: 'test@spec.com'
      fill_in 'First Name', with: 'Capy'
      fill_in 'Last Name', with: 'Bara'
      click_button 'Next'
      sleep 0.5

      fill_in 'Quote Name', with: 'Quote Name'
      fill_in 'Valid Until Date', with: Time.now + 1.day
      fill_in 'Estimated Delivery Date', with: Time.now + 1.day
      click_button 'Next'
      sleep 0.5

      click_link 'Add Line Item'
      sleep 0.5

      fill_in 'Name', with: 'Line Item Name'
      fill_in 'Description', with: 'Line Item Description'
      fill_in 'Quantity', with: 2
      fill_in 'Unit Price', with: 15
      click_button 'Submit'

      activity = quote.all_activities.to_a.select{ |a| a[:key] = 'quote.create' }
      expect(activity).to_not be_nil
    end

    scenario 'A quote being emailed to the customer' do
      visit edit_quote_path quote.id
      click_link 'Actions'
      click_link 'Email Quote'
      sleep 1

      click_button 'Submit'
      expect(current_path).to eq(edit_quote_path quote.id)
      expect(page).to have_selector '.modal-content-success', text: 'Your email was successfully sent!'

      activities_array = quote.all_activities.to_a
      activity = activities_array.select { |a| a[:key] = 'quote.emailed_customer' }
      expect(activity).to_not be_nil
    end

    scenario 'A quote being edited' do
      visit edit_quote_path quote.id
      click_link 'Details'
      fill_in 'Quote Name', with: 'Edited Quote Name'
      click_button 'Save'

      expect(current_path).to eq(quote_path quote.id)
      expect(page).to have_selector '.modal-content-success', text: 'Quote was successfully updated.'
      activity = quote.all_activities.to_a.select{ |a| a[:key] = 'quote.update' }
      expect(activity).to_not be_nil
    end

    scenario 'A line item changing' do
      visit edit_quote_path quote.id
      click_link 'Line Items'
      line_item_id = quote.line_items.first.id
      find("#line-item-#{line_item_id} .line-item-button[title='Edit']").click
      wait_for_ajax

      find("#line_item_#{line_item_id}_taxable").click
      find('.btn.update-line-items').click
      wait_for_ajax

      activity = quote.all_activities.to_a.select{ |a| a[:key] = 'quote.updated_line_item' }
      expect(activity).to_not be_nil
    end
  end
end
