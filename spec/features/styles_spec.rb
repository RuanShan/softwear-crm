require 'spec_helper'
include ApplicationHelper

feature 'Styles management' do

  given!(:valid_user) { create(:alternate_user) }
  before(:each) do
    login_as(valid_user)
  end

  let!(:style) { create(:valid_style)}


  scenario 'A user can see a list of styles' do
    visit root_path
    click_link 'styles_list_link'
    expect(current_path).to eq(styles_path)
    expect(page).to have_selector('.box-info')
  end

  scenario 'A user can create a new style' do
    visit styles_path
    click_link('Add a Style')
    fill_in 'style_name', :with => 'Sample Name'
    fill_in 'style_catalog_no', :with => '42'
    fill_in 'style_description', :with => 'Description'
    fill_in 'style_sku', :with => '1234'
    click_button('Create Style')
    expect(page).to have_selector '.modal-content-success', text: 'Style was successfully created.'
    expect(Style.find_by name: 'Sample Name').to_not be_nil
  end

  scenario 'A user can edit an existing style' do
    visit styles_path
    find("tr#style_#{style.id} a[data-action='edit']").click
    fill_in 'style_name', :with => 'Edited Style Name'
    click_button 'Update Style'
    expect(current_path).to eq(styles_path)
    expect(page).to have_selector '.modal-content-success', text: 'Style was successfully updated.'
    expect(style.reload.name).to eq('Edited Style Name')
  end

  scenario 'A user can delete an existing style', js: true do
    visit styles_path
    find("tr#style_#{style.id} a[data-action='destroy']").click
    page.driver.browser.switch_to.alert.accept
    wait_for_ajax
    expect(current_path).to eq(styles_path)
    expect(page).to have_selector '.modal-content-success', text: 'Style was successfully destroyed.'
    expect(style.reload.destroyed? ).to be_truthy
  end

end