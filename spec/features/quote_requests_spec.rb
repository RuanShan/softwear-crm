require 'spec_helper'
include ApplicationHelper

feature 'Quote Requests Management', js: true, quote_request_spec: true do
  given!(:quote_request) { create(:valid_quote_request_with_salesperson) }
  given(:quote_request_2) { create(:quote_request, name: 'aux') }
  given(:quote_request_3) { create(:quote_request, name: 'other') }
  given(:quote_request_4) { create(:quote_request, name: 'even more') }
  given!(:valid_user) { create(:alternate_user) }
  given(:next_button) { '.quote-request-next-button' }
  given(:previous_button) { '.quote-request-previous-button' }
  before(:each) { sign_in_as(valid_user) }

  scenario 'A user can view a list of quote requests' do
    visit quote_requests_path
    expect(page).to have_selector('.box-info')
  end

  scenario 'A user can quickly filter quote requests by status', js: true, story_709: true do
    quote_request.update_attributes! status: 'assigned'
    quote_request_2.update_attributes! status: 'pending'

    visit quote_requests_path

    expect(page).to have_content quote_request.name
    expect(page).to have_content quote_request_2.name

    all('.select2-selection').last.click
    find('.select2-results__option', text: 'Assigned').click
    sleep 2

    expect(Sunspot.session).to be_a_search_for QuoteRequest

    all('.select2-selection').last.click
    find('.select2-results__option', text: 'Pending').click
    sleep 2

    expect(Sunspot.session).to be_a_search_for QuoteRequest
  end

  scenario 'A user can change the assignment of a quote request', story_80: true, story_692: true do
    visit quote_requests_path
    all('span.editable').last.click
    find('div.editable-input').find("option[value='#{valid_user.id}']").click
    find('button.editable-submit').click
    wait_for_ajax
    expect(QuoteRequest.where(salesperson_id: valid_user.id)).to exist
  end

  scenario 'A user can assign an unassigned quote request', story_80: true, story_195: true, story_692: true do
    quote_request.salesperson_id = nil
    quote_request.save
    visit quote_requests_path
    all('span.editable').last.click
    page.find('div.editable-input').find("option[value='#{valid_user.id}']").click
    sleep 0.5
    page.find('button.editable-submit').click
    wait_for_ajax
    expect(QuoteRequest.where(salesperson_id: valid_user.id)).to exist
    expect(quote_request.reload.status).to eq 'assigned'
  end

  scenario 'A user can click next and previous unassigned quote request', retry: 3, next_and_previous: true do
    quote_request.update_attributes salesperson_id:   nil
    quote_request_2.update_attributes salesperson_id: valid_user.id
    quote_request_3.update_attributes salesperson_id: nil
    quote_request_4.update_attributes salesperson_id: nil

    visit quote_request_path(quote_request_3)
    find(previous_button).click
    sleep 1
    expect(current_path).to eq quote_request_path(quote_request_4)

    find(next_button).click
    sleep 1
    expect(current_path).to eq quote_request_path(quote_request_3)

    find(next_button).click
    sleep 1
    expect(current_path).to eq quote_request_path(quote_request)

    expect(page).to_not have_selector previous_button
  end

  scenario 'A user can click through their assigned quote requests', next_and_previous: true do
    quote_request.update_attributes salesperson_id:   valid_user.id
    quote_request_2.update_attributes salesperson_id: valid_user.id
    quote_request_3.update_attributes salesperson_id: nil
    quote_request_4.update_attributes salesperson_id: valid_user.id

    visit quote_request_path(quote_request_4)
    find(next_button).click
    sleep 1
    expect(current_path).to eq quote_request_path(quote_request_2)

    find(next_button).click
    sleep 1
    expect(current_path).to eq quote_request_path(quote_request)
    expect(page).to_not have_selector next_button

    find(previous_button).click
    sleep 1
    expect(current_path).to eq quote_request_path(quote_request_2)
  end

  scenario 'A user can add comments to a quote request', comments: true do
    visit quote_request_path(quote_request)
    fill_in 'Title', with: 'What is'
    fill_in 'Comment *', with: 'up, dude'
    click_button 'Add Comment'

    expect(page).to have_content "What is up, dude"
    visit quote_request_path(quote_request)
    expect(page).to have_content "What is up, dude"

    expect(quote_request.reload.comments.pluck(:comment)).to eq ['up, dude']
  end

  context 'In escalating a quote request to a quote' do
    background(:each) do
      visit quote_requests_path
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
  end

  scenario 'A user can change the status of a quote request', story_195: true, story_692: true do
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

  context 'Freshdesk' do
    scenario 'A user can create a freshdesk ticket', retry: 6, story_726: true do
      expect_any_instance_of(QuoteRequest).to receive(:create_freshdesk_ticket)

      visit quote_request_path(quote_request)
      sleep 1
      click_link 'Create Freshdesk Ticket'

      sleep 2

      expect(page).to have_content "Freshdesk ticket created!"
    end

    scenario 'A user can set up an email for freshdesk', freshdesk: true, story_726: true do
      quote_request.update_attributes!(
        freshdesk_ticket_id: 123
      )

      visit quote_request_path(quote_request)
      click_link 'Prepare for Freshdesk'

      fill_in 'Body', with: '<div class="spec726">Hey there</div>'
      sleep 1
      click_button 'Prepare for Freshdesk'
      expect(page).to have_css('.spec726', text: 'Hey there')
    end
  end
end
