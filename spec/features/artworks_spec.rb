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

  scenario 'A user can create an Artwork from the Artwork List', busted: true, retry: 2, no_ci: true do
    artwork_count = Artwork.count
    visit artworks_path
    find("a[href='/artworks/new']").click

    fill_in 'Name', with: 'Rspec Artwork'
    find(:css, 'textarea#artwork_description').set('description')
    fill_in 'Tags (separated by commas)', with: 'these,are,the,tags'
    fill_in 'Local file location', with: 'C:\some\windows\path\lol'
    find('#artwork_artwork_attributes_file', visible: false).set '/spec/fixtures/images/test.psd'
    find(:css, "textarea#artwork_artwork_attributes_description").set('description')
    find('#artwork_preview_attributes_file', visible: false).set '/spec/fixtures/images/macho.jpg'
    find(:css, "textarea#artwork_preview_attributes_description").set('description')

    click_button 'Create Artwork'

    sleep 1
    find(:css, 'button.close').click
    expect(page).to have_css("tr#artwork-row-#{artwork.id}")
    sleep 1 if ci?
    expect(Artwork.count).to eq artwork_count + 1
  end

  scenario 'A user can edit and update an Artwork from the Artwork List', no_ci: true, retry: 4, story_692: true do
    artwork_count = Artwork.count
    visit artworks_path
    find("a[href='#{edit_artwork_path(artwork)}']").click
    fill_in 'Name', with: 'Edited Artwork Name'
    click_button 'Update Artwork'
    expect(page).to have_content('Artwork was successfully updated')
    find(:css, 'button.close').click

    sleep 2
    expect(Artwork.where(name: 'Edited Artwork Name')).to exist
  end

  scenario 'A user can delete an Artwork from the Artwork List' do
    visit artworks_path
    find("a[href='#{artwork_path(artwork)}']").click
    find(:css, 'button.close').click
    expect(page).to_not have_css("tr#artwork-row-#{artwork.id}")
    expect(Artwork.where(name: 'Rspec Artwork')).to_not exist
  end

  scenario 'A user can view an image with a background color', story_981: true do
    artwork.update_column :bg_color, '#FF0000'
    visit artworks_path
    expect(page).to have_css "img[style='background-color: #FF0000;']"
  end
end
