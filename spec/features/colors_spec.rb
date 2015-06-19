require 'spec_helper'
include ApplicationHelper

feature 'Colors management', color_spec: true do
  given!(:color) { create(:valid_color) }
  given!(:valid_user) { create(:alternate_user) }

  background(:each) { login_as(valid_user) }

  scenario 'A user can see a list of colors' do
    visit root_path
    click_link 'colors_list_link'
    expect(page).to have_selector('.box-info')
  end

  scenario 'A user can create a new color', story_692: true do
    visit colors_path
    click_link('Add a color')
    fill_in 'color_name', with: 'Sample Name'
    fill_in 'color_sku', with: '042'
    click_button('Create Color')
    expect(page).to have_content 'Color was successfully created.'
    expect(Color.find_by name: 'Sample Name').to_not be_nil
  end

  scenario 'A user can edit an existing color', story_692: true do
    visit edit_color_path color.id
    fill_in 'color_name', with: 'Edited Color Name'
    click_button 'Update Color'
    expect(page).to have_content 'Color was successfully updated.'
    expect(color.reload.name).to eq('Edited Color Name')
  end

  scenario 'A user can delete an existing color', js: true, story_692: true do
    visit colors_path
    find("tr#color_#{color.id} a[data-action='destroy']").click
    page.driver.browser.switch_to.alert.accept
    wait_for_ajax
    expect(page).to have_content 'Color was successfully destroyed.'
    expect(color.reload.deleted_at).not_to eq(nil)
  end
end
