require 'spec_helper'
include ApplicationHelper

feature 'Artwork Request Features', js: true, artwork_request_spec: true do
  given!(:artwork_request) { create(:valid_artwork_request) }
  given!(:valid_user) { create(:alternate_user) }
  before(:each) { login_as(valid_user) }

  scenario 'A user can view a list of artwork requests from the root path via Orders', no_ci: true do
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
    if ci?
      visit artwork_requests_path
    else
      unhide_dashboard
      click_link 'Artwork'
      click_link 'Artwork Requests'
    end
    expect(page).to have_css('h1', text: 'Artwork Requests')
    expect(page).to have_css('table#artwork-request-table')
  end

  scenario 'A user can add an artwork request', what: true, retry: 3, story_692: true do
    visit new_order_artwork_request_path(artwork_request.jobs.first.order)
    sleep 1

    find('#artwork_request_job_ids').select artwork_request.jobs.first.id

    find_by_id('artwork_imprint_method_fields').find("option[value='#{artwork_request.imprint_method.id}']").click
    sleep 0.5
    find_by_id('imprint_method_print_locations').find("option[value='#{artwork_request.print_location.id}']").click
    find(:css, "div.icheckbox_minimal-grey[aria-checked='false']").click
    fill_in 'artwork_request_deadline', with: '01/23/1992 8:55 PM'
    find_by_id('artwork_request_artist_id').find("option[value='#{artwork_request.artist_id}']").click
    fill_in 'Description', with: 'hello'

    click_button 'Create Artwork Request'
    expect(page).to have_selector('.modal-content-success')
    find(:css, 'button.close').click
    expect(ArtworkRequest.where(description: 'hello')).to exist
    expect(page).to have_css("div#artwork-request-#{artwork_request.id}")
  end

  # NOTE this fails in CI for absolutely no reason
  scenario 'A user can edit an artwork request', retry: 4 do
    visit "/orders/#{artwork_request.jobs.first.order.id}/edit#artwork"
    find("a[href='/orders/1/artwork_requests/#{artwork_request.id}/edit']").click
    fill_in 'Description', with: 'edited'
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
    expect(artwork_request.reload.deleted_at).to be_truthy
  end
end
