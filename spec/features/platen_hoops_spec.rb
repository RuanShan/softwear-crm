require 'spec_helper'
include ApplicationHelper

feature 'Platens and Hoops management', story_866: true do
  given!(:valid_user) { create(:user) }
  before(:each) do
    login_as(valid_user)
  end

  let!(:platen_hoop) { create(:platen_hoop) }

  scenario 'User views list of existing platen/hoops' do
    visit root_path
    click_link 'Configuration'
    click_link 'Platens/Hoops'
    expect(page).to have_css("tr##{model_table_row_id(platen_hoop)}")
  end

  scenario 'User creates a new platen/hoop' do
    visit platen_hoops_path
    click_link 'Add a Platen/Hoop'
    fill_in 'Name', with: 'New Platen/Hoop'
    fill_in 'Max width', with: '10.5'
    fill_in 'Max height', with: '7.6'
    click_button 'Create Platen/Hoop'
    expect(PlatenHoop.where(name: 'New Platen/Hoop', max_width: 10.5, max_height: 7.6)).to exist
    expect(page).to have_selector('#flash_notice', text: 'Platen hoop was successfully created.')
  end

  scenario 'User deletes an existing platen/hoop', js: true, story_692: true do
    visit platen_hoops_path
    find("tr#platen_hoop_#{platen_hoop.id} a[data-action='destroy']").click
    sleep 2 if ci?
    page.driver.browser.switch_to.alert.accept
    wait_for_ajax
    expect(PlatenHoop.where(id: platen_hoop.id)).to_not exist
  end

  scenario 'User edits an existing platen/hoop' do
    visit platen_hoops_path
    find("tr#platen_hoop_#{platen_hoop.id} a[data-action='edit']").click
    fill_in 'Name', with: 'Edited Platen/Hoop Name'
    click_button 'Update Platen/Hoop'
    expect(platen_hoop.reload.name).to eq('Edited Platen/Hoop Name')
    expect(page).to have_selector('#flash_notice', text: 'Platen hoop was successfully updated.')
  end

end
