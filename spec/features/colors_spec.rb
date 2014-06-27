require 'spec_helper'
include ApplicationHelper

feature 'Colors management', color_spec: true do

  given!(:valid_user) { create(:alternate_user) }
  before(:each) do
    login_as(valid_user)
  end

  given!(:color) { create(:valid_color) }


  scenario 'A user can see a list of colors' do
    visit root_path
    click_link 'colors_list_link'
    expect(current_path).to eq(colors_path)
    expect(page).to have_selector('.box-info')
  end

  scenario 'A user can create a new color' do
    visit colors_path
    click_link('Add a color')
    fill_in 'color_name', :with => 'Sample Name'
    fill_in 'color_sku', :with => '042'
    click_button('Create Color')
    expect(page).to have_selector '.modal-content-success', text: 'Color was successfully created.'
    expect(Color.find_by name: 'Sample Name').to_not be_nil
  end

  scenario 'A user can edit an existing color' do
    visit edit_color_path color.id
    fill_in 'color_name', :with => 'Edited Color Name'
    click_button 'Update Color'
    expect(current_path).to eq(colors_path)
    expect(page).to have_selector '.modal-content-success', text: 'Color was successfully updated.'
    expect(color.reload.name).to eq('Edited Color Name')
  end

  scenario 'A user can delete an existing color', js: true do
    visit colors_path
    find("tr#color_#{color.id} a[data-action='destroy']").click
    page.driver.browser.switch_to.alert.accept
    wait_for_ajax
    expect(current_path).to eq(colors_path)
    expect(page).to have_selector '.modal-content-success', text: 'Color was successfully destroyed.'
    expect(color.reload.destroyed? ).to be_truthy
  end
end
