require 'spec_helper'
include ApplicationHelper

feature 'Quote Requests Management', js: true, quote_request_spec: true do
  given!(:quote_request) { create(:valid_quote_request_with_salesperson) }
  given!(:valid_user) { create(:alternate_user) }
  before(:each) { login_as(valid_user) }

  scenario 'A user can view a list of quote requests' do
    visit root_path
    unhide_dashboard
    click_link 'quotes_list'
    click_link 'quote_requests_link'
    sleep 10
    expect(page).to have_selector('.box-info')
  end

  scenario 'A user can change the assignment of a quote request', story_80: true, story_692: true do
    visit quote_requests_path
    page.find('span.editable').click
    page.find('div.editable-input').find("option[value='#{valid_user.id}']").click
    page.find('button.editable-submit').click
    wait_for_ajax
    expect(QuoteRequest.where(salesperson_id: valid_user.id)).to exist
  end

  scenario 'A user can assign an unassigned quote request', story_80: true, story_195: true, story_692: true do
    quote_request.salesperson_id = nil
    quote_request.save
    visit quote_requests_path
    page.find('span.editable').click
    page.find('div.editable-input').find("option[value='#{valid_user.id}']").click
    page.find('button.editable-submit').click
    wait_for_ajax
    expect(QuoteRequest.where(salesperson_id: valid_user.id)).to exist
    expect(quote_request.reload.status).to eq 'assigned'
  end

  context 'In escalating a quote request to a quote' do
    background(:each) do
      visit root_path
      unhide_dashboard
      click_link 'Quotes'
      click_link 'Quote Requests'
      find("a[data-action='quote']").click
    end

    scenario 'A user can create a Quote from a Quote Request', story_79: true, story_195: true, create_quote: true, story_692: true do
      expect(page).to have_css("#quote_email[value='#{quote_request.email}']")

      click_button 'Next'
      sleep 0.5

      fill_in 'Quote Name', with: 'Quote Name'
      find('#quote_quote_source').find("option[value='Other']").click
      sleep 1
      fill_in 'Valid Until Date', with: (2.days.from_now).strftime('%m/%d/%Y %I:%M %p')
      fill_in 'Delivery Date', with: (1.days.from_now).strftime('%m/%d/%Y %I:%M %p')
      click_button 'Next'
      wait_for_ajax
      sleep 1
      click_button 'Submit'
      sleep 2
      wait_for_ajax
      expect(page).to have_content 'Quote was successfully created.'
      expect(Quote.last.quote_request_ids).to eq([quote_request.id])
      expect(quote_request.reload.status).to eq 'quoted'
    end

    context 'when a user fails to fill out the quote form correctly' do
      scenario 'entries are still created in the linker table', story_248: true, story_699: true do
        expect(QuoteRequestQuote.count).to eq(0)
        click_button 'Next'
        sleep 0.5
        click_button 'Next'
        sleep 0.5
        click_button 'Submit'
        expect(page).to have_selector '#errorsModal .modal-content-error', text: 'There was an error saving the quote'
        close_error_modal

        select 'Phone Call', from: 'quote_quote_source'
        fill_in 'Valid Until Date', with: (2.days.from_now).strftime('%m/%d/%Y %I:%M %p')
        fill_in 'Delivery Date', with: (1.days.from_now).strftime('%m/%d/%Y %I:%M %p')
        click_button 'Next'
        wait_for_ajax
        sleep 1
        click_button 'Submit'
        wait_for_ajax
        sleep 1
        expect(page).to have_content 'Quote was successfully created.'
        expect(QuoteRequestQuote.count).to eq(1)
      end
    end
  end

  scenario 'A user can change the status of a quote request', story_195: true, current: true, story_692: true do
    visit quote_request_path(quote_request)

    find(".editable[data-placeholder='Status']").click
    wait_for_ajax
    find(".form-control.input-sm").select("pending")

    find('.glyphicon-ok').click
    wait_for_ajax

    expect(page).to have_content 'pending'
    expect(QuoteRequest.where(status: 'pending')).to exist
  end

  context 'when more then 1 user is present' do
    let!(:new_salesperson) { create(:user) }

    scenario 'A user can reassign a quote requests salesperson', story_272: true do
      visit quote_request_path(quote_request)
      find("span[data-name='salesperson_id']").click
      find("div.editable-input select.form-control").click
      find("div.editable-input select option[value='#{new_salesperson.id}']").click
      find("div.editable-buttons button[type='submit']").click
      expect(page).to have_content new_salesperson.full_name
    end
  end
end
