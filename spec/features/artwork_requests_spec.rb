require 'spec_helper'
include ApplicationHelper

feature 'Artwork Request Features', js: true, artwork_request_spec: true do
  given!(:artwork_request) { create(:valid_artwork_request) }
  given!(:valid_user) { create(:alternate_user) }
  before(:each) { login_as(valid_user) }

  scenario 'A user can view a list of artwork requests from the root path via Orders' do
    visit root_path
    unhide_dashboard
    click_link 'Orders'
    click_link 'List'
    find("a[href='/orders/#{artwork_request.jobs.first.order.id}/edit']").click
    find("a[href='#artwork']").click
    expect(page).to have_css('h3', text: 'Artwork Requests')
    expect(page).to have_css('div.artwork-request-list')
  end

  scenario 'A user can view a list of artwork requests from the root path via Artwork' do
    visit root_path
    unhide_dashboard
    click_link 'Artwork'
    click_link 'Artwork Requests'
    expect(page).to have_css('h1', text: 'Artwork Requests')
    expect(page).to have_css('table#artwork-request-table')
  end

  scenario 'A user can add an artwork request', retry: 3 do
    visit "/orders/#{artwork_request.jobs.first.order.id}/edit#artwork"
    page.find("a[href='#{new_order_artwork_request_path(artwork_request.jobs.first.order)}']").click
    sleep 0.5
    page.find('div.chosen-container').click
    sleep 1
    page.find('li.active-result').click
    page.find_by_id('artwork_imprint_method_fields').find("option[value='#{artwork_request.imprint_method.id}']").click
    sleep 0.5
    page.find_by_id('imprint_method_print_locations').find("option[value='#{artwork_request.print_location.id}']").click
    find(:css, "div.icheckbox_minimal-grey[aria-checked='false']").click
    fill_in 'artwork_request_deadline', with: '01/23/1992 8:55 PM'
    page.find_by_id('artwork_request_artist_id').find("option[value='#{artwork_request.artist_id}']").click
    find(:css, "div[class='note-editable'").set('hello')
    click_button 'Create Artwork Request'
    expect(page).to have_selector('.modal-content-success')
    find(:css, 'button.close').click
    expect(ArtworkRequest.where(description: 'hello')).to exist
    expect(page).to have_css("div#artwork-request-#{artwork_request.id}")
  end

  scenario 'A user can edit an artwork request' do
    visit "/orders/#{artwork_request.jobs.first.order.id}/edit#artwork"
    find("a[href='/orders/1/artwork_requests/#{artwork_request.id}/edit']").click
    find(:css, "div[class='note-editable'").set('edited')
    select 'Normal', from: 'Priority'
    click_button 'Update Artwork Request'
    expect(page).to have_selector('.modal-content-success')
    find(:css, "button.close").click
    expect(ArtworkRequest.where(description: 'edited')).to exist
  end

  scenario 'A user can delete an artwork request' do
    visit "/orders/#{artwork_request.jobs.first.order.id}/edit#artwork"
    click_link 'Delete'
    expect(page).to have_selector('.modal-content-success')
    find(:css, 'button.close').click
    expect(ArtworkRequest.where(id: artwork_request.id)).to_not exist
    expect(page).to_not have_css("div#artwork-request-#{artwork_request.id}")
    expect(artwork_request.reload.destroyed?).to be_truthy
  end
end
