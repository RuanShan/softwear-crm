require 'spec_helper'
include ApplicationHelper

feature 'Artwork Request Features', js: true, artwork_request_spec: true do
  given!(:valid_user) { create(:alternate_user) }
  before(:each) do
    login_as(valid_user)
  end
  given!(:artwork_request) { create(:valid_artwork_request)}

  # scenario 'A user can add an artwork request', js: true, pending: 'Unclear how to select from chosen and check checkbox' do
    # visit '/orders/1/edit#artwork'
    # page.find('#new_artwork_request').click
    # page.find("select[name='artwork_request[job_ids][]']")
    # page.find("[name='artwork_request[job_ids][]']")
    #
    # sfind_field("[name='artwork_request[job_ids][]']")
    #
    # select_from_chosen('Test Job 1', from: 'job_ids')
    #
    #
    #
    # select job
    # imprint_method
    # page.find_by_id('artwork_imprint_method_fields').find("option[value='#{artwork_request.imprint_method.id}']").click
    # wait_for_ajax
    # page.find_by_id('imprint_method_print_locations').find("option[value='#{artwork_request.print_location.id}']").click
    #   ink colors
    # page.find(:xpath, "//div[contains(@id, 'artwork_request_ink_color_ids_')]")
    # find(:css, "#artwork_request_ink_color_ids_[value='#{artwork_request.ink_color_ids.first}']").set(true)
    #   print location
    # deadline
    # artist
    # description via summernote
    # submit
    #
    #
    # page.find('#jobs_tokenfield_chosen').click
    # page.find_field(options['Jobs'])
    # page.select 'Test Job 1', from: 'Jobs'
    #
    #
    #
    # page.check('red')
    # fill_in 'artwork_request_deadline', with: '01/23/1992 8:55 PM'
    # page.find_by_id('artwork_request_artist_id').find("option[value='#{artwork_request.artist_id}']").click
    # find(:css, "div[class='note-editable'").set('hello')
    # click_button 'Create Artwork Request'
    # expect(ArtworkRequest.where(description: 'hello')).to exist
    # expect(page).to have_css("div[artwork-request-#{artwork_request.id}]")
    # expect('.the-notes').to have_button('.fa fa-2x fa-edit', text: 'Edit')
    # expect('.the-notes').to have_button('.fa fa-2x danger fa-times-circle', text: 'Delete')
  # end

  scenario 'A user can edit an artwork request', js: true do
    visit '/orders/1/edit#artwork'
    find("a[href='/orders/1/artwork_requests/#{artwork_request.id}/edit']").click
    find(:css, "div[class='note-editable'").set('edited')
    select 'Normal', from: 'Priority'
    click_button 'Update Artwork Request'
    wait_for_ajax
    expect(ArtworkRequest.where(description: 'edited')).to exist
  end
  # scenario 'A user can edit an artwork request', js: true do
  #   visit '/orders/1/edit#artwork'
  #   find("a[href='/orders/1/artwork_requests/#{artwork_request.id}/edit']").click
  #   find(:css, "div[class='note-editable'").set('edited')
  #   click_button 'Update Artwork Request'
  #   wait_for_ajax
  #   expect(artwork_request.reload.description).to eq('edited')
  # end

  # scenario 'A user can delete an artwork request', js: true do
  #   visit '/orders/1/edit#artwork'
  #   click_link 'Delete'
  #   wait_for_ajax
  #   expect(ArtworkRequest.where(id: artwork_request.id)).to_not exist
  #   expect(artwork_request.reload.destroyed? ).to be_truthy
  #
  # end
  #
  # scenario 'A user can view a list of artwork requests' do
  #   visit '/orders/1/edit#artwork'
  #   expect(page).to have_css('h3', text: 'Artwork Requests')
  #   expect(page).to have_css('div.artwork-request-list', visible: false)
  # end

end