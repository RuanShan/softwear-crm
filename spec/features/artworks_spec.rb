require 'spec_helper'
include ApplicationHelper

feature 'Artwork Features', artworks_spec: true do
  given!(:valid_user) { create(:alternate_user) }
  before(:each) do
    login_as(valid_user)
  end
  given!(:artwork) { create(:valid_artwork)}

  scenario 'A user can view a list of Artworks' do
    visit root_path
    find("a#artwork-sidebar").click
    click_link 'Artwork List'
    expect(page).to have_css("table#artwork-table")
    expect(page).to have_css("tr#artwork-row-#{artwork.id}")
  end

  scenario 'A user can create an Artwork from the Artwork List', js: true do
    visit artworks_path
    find("a[href='/artworks/new']").click
    fill_in 'Name', with: 'Rspec Artwork'
    sleep 0.5
    find(:css, "textarea#artwork_description").set('description')
    fill_in 'Tags (separated by commas)', with: 'these,are,the,tags'
    sleep 0.5
    attach_file('Artwork', "#{Rails.root}" + '/spec/fixtures/images/macho.jpg')
    sleep 0.5
    find(:css, "textarea#artwork_artwork_attributes_description").set('description')
    sleep 0.5
    attach_file('Preview', "#{Rails.root}" + '/spec/fixtures/images/macho.jpg')
    sleep 0.5
    find(:css, "textarea#artwork_preview_attributes_description").set('description')
    sleep 0.5
    click_button 'Create Artwork'
    sleep 0.5
    expect(page).to have_selector('.modal-content-success')
    sleep 0.5
    find(:css, "button.close").click
    sleep 0.5
    expect(page).to have_css("tr#artwork-row-#{artwork.id}")
    expect(Artwork.where(name: 'Rspec Artwork')).to exist
  end

  scenario 'A user can search exiting artwork for tags and names', js: true, solr: true do
    visit artworks_path
    expect(page).to have_css("tr#artwork-row-#{artwork.id}")
    find(:css, "input#search_artwork_fulltext").set('adsflk;jasdpfiuawekfjasdf;klj')
    click_button 'Search'
    expect(page).to_not have_css("tr#artwork-row-#{artwork.id}")
    find(:css, "input#search_artwork_fulltext").set('')
    click_button 'Search'
    expect(page).to have_css("tr#artwork-row-#{artwork.id}")
    find(:css, "input#search_artwork_fulltext").set('Artwork')
    click_button 'Search'
    expect(page).to have_css("tr#artwork-row-#{artwork.id}")
  end

  scenario 'A user can edit and update an Artwork from the Artwork List', js: true  do
    visit artworks_path
    find("a[href='#{edit_artwork_path(artwork)}']").click
    fill_in 'Name', with: 'Edited Artwork Name'
    sleep 0.5
    click_button 'Update Artwork'
    expect(page).to have_selector('.modal-content-success')
    sleep 0.5
    find(:css, "button.close").click
    sleep 0.5
    expect(page).to have_css("tr#artwork-row-#{artwork.id}")
    expect(Artwork.where(name: 'Edited Artwork Name')).to exist
  end

  scenario 'A user can delete an Artwork from the Artwork List', js: true do
    visit artworks_path
    find("a[href='#{artwork_path(artwork)}']").click
    expect(page).to have_selector('.modal-content-success')
    find(:css, "button.close").click
    expect(page).to_not have_css("tr#artwork-row-#{artwork.id}")
    expect(Artwork.where(name: 'Rspec Artwork')).to_not exist
  end
end