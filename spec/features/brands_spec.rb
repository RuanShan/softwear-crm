require 'spec_helper'
include ApplicationHelper

feature 'Brands management', brand_spec: true do
  given!(:brand) { create(:valid_brand) }
  given!(:valid_user) { create(:alternate_user) }

  background(:each) { login_as(valid_user) }

  scenario 'A user can see a list of brands' do
    visit root_path
    click_link 'brands_list_link'
    expect(page).to have_selector('.box-info')
  end

  scenario 'A user can create a new brand', story_692: true do
    visit brands_path
    click_link('Add a Brand')
    fill_in 'brand_name', with: 'Sample Name'
    fill_in 'brand_sku', with: '42'
    click_button('Create Brand')
    expect(page).to have_content 'Brand was successfully created.'
    expect(Brand.find_by name: 'Sample Name').to_not be_nil
  end

  scenario 'A user can edit an existing brand', story_692: true do
    visit edit_brand_path brand.id
    fill_in 'brand_name', with: 'Edited Brand Name'
    click_button 'Update Brand'
    expect(page).to have_content 'Brand was successfully updated.'
    expect(brand.reload.name).to eq('Edited Brand Name')
  end

  scenario 'A user can delete an existing brand', js: true, story_692: true do
    visit brands_path
    find("tr#brand_#{brand.id} a[data-action='destroy']").click
    page.driver.browser.switch_to.alert.accept
    wait_for_ajax
    expect(page).to have_content 'Brand was successfully destroyed.'
    expect(brand.reload.deleted_at).not_to eq(nil)
  end
end
