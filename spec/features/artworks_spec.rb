require 'spec_helper'
include ApplicationHelper

feature 'Artwork Features', js: true, artwork_spec: true do
  given!(:order) { create(:order_with_job) }
  given!(:imprint) { create(:valid_imprint) }
  given!(:request) { create(:valid_artwork_request) }
  given!(:artwork) { create(:valid_artwork) }
  given!(:doc_art) { create(:doc_type_preview) }
  given!(:valid_user) { create(:alternate_user) }

  before :each do
    sign_in_as(valid_user)
    order.jobs.first.imprints << imprint
    order.jobs.first.imprints.first.artwork_requests << request
    artwork.artwork_requests << request
  end
  
  context 'Artwork Activities' do

    before(:each) do
      PublicActivity.with_tracking do
        visit artworks_path
        sleep 1
        click_link "Add Artwork"
        sleep 1
        fill_in "Name", with: "This is a new artwork"
        find(:css, 'textarea#artwork_description').set('new description')
        fill_in 'Tags (separated by commas)', with: 'these,are,the,new,tags'
        fill_in 'Local file location', with: 'C:\some\windows\path\lol'
        find('#artwork_artwork_attributes_file', visible: false).set "#{Rails.root}/spec/fixtures/images/macho.png"
        find(:css, "textarea#artwork_artwork_attributes_description").set('description')
        find('#artwork_preview_attributes_file', visible: false).set "#{Rails.root}/spec/fixtures/images/macho.png"
        find(:css, "textarea#artwork_preview_attributes_description").set('description')

        click_button 'Create Artwork'
        sleep 2
        find(:css, "button[type='button'][class='close']").click
      end 
    end

    scenario 'A user can create an artwork and see the activity in the show modal' do
      new_artwork = Artwork.find_by(name: "This is a new artwork")
      
      find(:css, "a[href='/artworks/#{new_artwork.id}?disable_buttons=true']").click 
      sleep 1
      expect(page).to have_content "created Artwork"
    end

    scenario 'A user can update an artwork and see the activity in the show modal' do
      new_artwork = Artwork.find_by(name: "This is a new artwork")
      
      PublicActivity.with_tracking do
        new_artwork.description = "This is an alternate desc"
        new_artwork.save
      end

      find(:css, "a[href='/artworks/#{new_artwork.id}?disable_buttons=true']").click 
      sleep 1

      expect(page).to have_content "created Artwork"
      expect(page).to have_content "has updated \"#{new_artwork.name}\""
    end

  end

  scenario 'A user can click on the order link and visit the edit order page' do
    other_order = artwork.artwork_requests.first.order
    
    visit artworks_path
    expect(page).to have_link "Order #{other_order.id}"
    sleep 1
    click_link "Order #{other_order.id}"
    sleep 1
    expect(page).to have_content "Order ##{other_order.id}"
    expect(page).to have_content "#{other_order.name}"
  end
  
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

  scenario 'A user can view a list of Artworks and only see thumbs for image types' do
    if ci?
      visit artworks_path
    else
      visit root_path
      unhide_dashboard
      click_link 'Artwork'
      click_link 'Artwork List'
    end

    expect(page).to have_css("tr[id^='artwork']", count: 2)
    expect(page).to have_css("img[src^='/system/']", count: 1)
   
  end
  
  context 'A user can create an Artwork from the Artwork List', busted: true, retry: 2, no_ci: true do
    
    scenario 'A user can upload an image file' do
      artwork_count = Artwork.count
      visit artworks_path
      find("a[href='/artworks/new']").click

      fill_in 'Name', with: 'Rspec Artwork'
      find(:css, 'textarea#artwork_description').set('description')
      fill_in 'Tags (separated by commas)', with: 'these,are,the,tags'
      fill_in 'Local file location', with: 'C:\some\windows\path\lol'
      find('#artwork_artwork_attributes_file', visible: false).set "#{Rails.root}/spec/fixtures/images/macho.png"
      find(:css, "textarea#artwork_artwork_attributes_description").set('description')
      find('#artwork_preview_attributes_file', visible: false).set "#{Rails.root}/spec/fixtures/images/macho.png"
      find(:css, "textarea#artwork_preview_attributes_description").set('description')

      click_button 'Create Artwork'

      sleep 1
      #find(:css, 'button.close').click
      expect(page).to have_css("tr#artwork-row-#{artwork.id}")
      sleep 1 if ci?
      expect(Artwork.count).to eq artwork_count + 1
    end

    scenario 'A user can upload a text file' do
      artwork_count = Artwork.count
      visit artworks_path
      find("a[href='/artworks/new']").click

      fill_in 'Name', with: 'Rspec Artwork'
      find(:css, 'textarea#artwork_description').set('description')
      fill_in 'Tags (separated by commas)', with: 'these,are,the,tags'
      fill_in 'Local file location', with: 'C:\some\windows\path\lol'
      find('#artwork_artwork_attributes_file', visible: false).set "#{Rails.root}/spec/fixtures/fba/PackingSlipBadSku.txt"
      find(:css, "textarea#artwork_artwork_attributes_description").set('description')
      find('#artwork_preview_attributes_file', visible: false).set "#{Rails.root}/spec/fixtures/fba/PackingSlipBadSku.txt"
      find(:css, "textarea#artwork_preview_attributes_description").set('description')

      click_button 'Create Artwork'

      sleep 1
      find(:css, 'button.close').click
      expect(page).to have_css("tr#artwork-row-#{artwork.id}")
      sleep 1 if ci?
      expect(Artwork.count).to eq artwork_count + 1
    end
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
