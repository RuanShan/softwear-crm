require 'spec_helper'
include ApplicationHelper

feature 'Artwork Features', js: true, artwork_spec: true do
  given!(:artwork) { create(:valid_artwork) }
  given!(:valid_user) { create(:alternate_user) }
  before(:each) { login_as(valid_user) }

  scenario 'A user can view a list of Artworks' do
    if ci?
      visit artworks_path
    else
      visit root_path
      unhide_dashboard
      click_link 'Artwork'
      click_link 'Artwork List'
    end
    expect(page).to have_css('table#artwork-table')
    expect(page).to have_css("tr#artwork-row-#{artwork.id}")
  end

  scenario 'A user can create an Artwork from the Artwork List', retry: 2 do
    artwork_count = Artwork.count
    visit artworks_path
    find("a[href='/artworks/new']").click
    fill_in 'Name', with: 'Rspec Artwork'
    find(:css, 'textarea#artwork_description').set('description')
    fill_in 'Tags (separated by commas)', with: 'these,are,the,tags'
    attach_file('Artwork', "#{Rails.root}" + '/spec/fixtures/images/macho.jpg')
    find(:css, "textarea#artwork_artwork_attributes_description").set('description')
    attach_file('Preview', "#{Rails.root}" + '/spec/fixtures/images/macho.jpg')
    find(:css, "textarea#artwork_preview_attributes_description").set('description')
    click_button 'Create Artwork'
    sleep 1
    expect(page).to have_css('.modal-content-success')
    find(:css, 'button.close').click
    expect(page).to have_css("tr#artwork-row-#{artwork.id}")
    sleep 1 if ci?
    expect(Artwork.count).to eq artwork_count + 1
  end

#  scenario 'A user can search existing artwork for tags and names', solr: true do
#    visit artworks_path
#    expect(page).to have_css("tr#artwork-row-#{artwork.id}")
#    find(:css, "input#search_artwork_fulltext").set('adsflk;jasdpfiuawekfjasdf;klj')
#    click_button 'Search'
#    expect(page).to_not have_css("tr#artwork-row-#{artwork.id}")
#    find(:css, "input#search_artwork_fulltext").set('')
#    click_button 'Search'
#    expect(page).to have_css("tr#artwork-row-#{artwork.id}")
#    find(:css, "input#search_artwork_fulltext").set('Artwork')
#    click_button 'Search'
#    expect(page).to have_css("tr#artwork-row-#{artwork.id}")
#  end

  scenario 'A user can edit and update an Artwork from the Artwork List', retry: 2, story_692: true, maybe_nogood_for_ci: true do
    artwork_count = Artwork.count
    visit artworks_path
    find("a[href='#{edit_artwork_path(artwork)}']").click
    fill_in 'Name', with: 'Edited Artwork Name'
    click_button 'Update Artwork'
    wait_for_ajax
    expect(page).to have_css('.modal-content-success')
    find(:css, 'button.close').click
    expect(page).to have_css("tr#artwork-row-#{artwork.id}")
    expect(Artwork.count).to eq artwork_count + 1
  end

  scenario 'A user can delete an Artwork from the Artwork List' do
    visit artworks_path
    find("a[href='#{artwork_path(artwork)}']").click
    expect(page).to have_selector('.modal-content-success')
    find(:css, 'button.close').click
    expect(page).to_not have_css("tr#artwork-row-#{artwork.id}")
    expect(Artwork.where(name: 'Rspec Artwork')).to_not exist
  end
end
