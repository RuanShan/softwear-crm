require 'spec_helper'
include ApplicationHelper

feature 'Artwork Request Features', js: true, artwork_request_spec: true do
  given!(:valid_user) { create(:alternate_user) }
  before(:each) do
    login_as(valid_user)
  end
  given!(:order) { create(:order_with_job) }
  given(:job) { order.jobs.first }
  given!(:imprint_method) { create(:valid_imprint_method_with_color_and_location)}
  given!(:valid_user) { create(:user) }
  given!(:artwork_request) { create(:valid_artwork_request)}

  scenario 'A user can add an artwork request' , js: true do
    visit '/orders/1/edit#artwork'
    click_button 'Add Artwork Request'
    fill_in 'Jobs', with: 'Test Kareem Abdul-Job-bar'
    select 'Test Name - Test Name', from: 'Imprint method'
    wait_for_ajax
    select 'Traps', from: 'Print locations'
    check 'Test Color'
    check 'Test Color Rocky IV'
    find(".glyphicon-calendar glyphicon").click
    select 'Ricky Winowiecki', from: 'Artist'
    fill_in 'Description', with: 'Do we have another sorbet?'
    click_button 'Create Artwork Request'
    expect(ArtworkRequest.where(description: 'Do we have another sorbet?')).to exist
    expect(page).to have_selector('.artwork-request-title', text: 'Artwork Request for Test Kareem Abdul-Job-bar')
    expect('.the-notes').to have_button('.fa fa-2x fa-edit', text: 'Edit')
    expect('.the-notes').to have_button('.fa fa-2x danger fa-times-circle', text: 'Delete')
  end

  scenario 'A user can delete an artwork request', js: true do
    visit '/orders/1/edit#artwork'
    first("a[data-method='delete']").click
    page.driver.browser.switch_to.alert.accept
    wait_for_ajax
    expect(ArtworkRequest.where(id: artwork_request.id)).to_not exist
    expect(page).to_not have_content artwork_request.description
  end

  scenario 'A user can edit an artwork request', js: true do
    visit '/orders/1/edit#artwork'
    first(".fa-edit").click
    fill_in 'Description', with: 'Whens the cousins club meeting babe? Cause I wanna be there.'
    click_button 'Update Artwork Request'
    expect(artwork_request.reload.description).to eq('Whens the cousins club meeting babe? Cause I wanna be there.')
  end

  scenario 'A user can view a list of artwork requests' do
    visit '/orders/1/edit#artwork'
    expect(page).to have_selector('#artwork-request-list')
  end

end