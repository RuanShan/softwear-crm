require 'spec_helper'
include ApplicationHelper

feature 'Imprintables management', imprintable_spec: true do
  given!(:valid_user) { create(:alternate_user) }
  before(:each) do
    login_as(valid_user)
  end

  given!(:imprintable) { create(:valid_imprintable) }

  scenario 'A user can see a list of imprintables' do
    visit root_path
    click_link 'imprintables_list_link'
    expect(page).to have_selector('.box-info')
    expect(current_path).to eq(imprintables_path)
  end

  scenario 'A user can create a new imprintable', js: true do
    visit imprintables_path
    click_link('Add an Imprintable')
    fill_in 'Special Considerations', :with => 'Special Consideration'
    page.find_by_id('imprintable_sizing_category').find("option[value='#{imprintable.sizing_category}']").click
    page.find_by_id('imprintable_brand_id').find("option[value='#{imprintable.brand.id}']").click
    page.find_by_id('imprintable_style_id').find("option[value='#{imprintable.style.id}']").click
    find_button('Create Imprintable').click
    expect(page).to have_selector '.modal-content-success', text: 'Imprintable was successfully created.'
    expect(current_path).to eq(imprintable_path 2)
    expect(Imprintable.find_by special_considerations: 'Special Consideration').to_not be_nil
  end

  describe 'Tagging', js: true do
    let!(:imprintable_two) { create(:valid_imprintable) }
    let!(:imprintable_three) { create(:valid_imprintable) }
    scenario 'A user can tag an imprintable' do
      visit imprintables_path
      find("tr#imprintable_#{imprintable.id} a[data-action='edit']").click
      fill_in 'Tag List', with: 'cotton'
      find_button('Update Imprintable').click
      expect(page).to have_selector '.modal-content-success', text: 'Imprintable was successfully updated.'
      expect(current_path).to eq(edit_imprintable_path imprintable.id)
      expect(imprintable.reload.tag_list.include? 'cotton').to be_truthy
    end

    scenario 'A user can filter a list of imprintables by tag' do
      visit imprintables_path
      find("tr#imprintable_#{imprintable.id} a[data-action='edit']").click
      fill_in 'Tag List', with: 'cotton'
      find_button('Update Imprintable').click
      expect(page).to have_selector '.modal-content-success', text: 'Imprintable was successfully updated.'
      visit imprintables_path
      expect(page).to have_link('cotton', href: '/tags/cotton')
      find(:xpath, "//*[@id='imprintable_#{imprintable.id}']/td[9]/a[1]").click
      expect(page).to have_selector("tr#imprintable_#{imprintable.id}")
      expect(page).to_not have_selector("tr#imprintable_#{imprintable_two.id}")
      expect(page).to_not have_selector("tr#imprintable_#{imprintable_three.id}")
    end
  end


  describe 'There is a store available', js: true, pending: true do
    let!(:store) { create(:valid_store) }
    scenario 'A user can utilize sample location token input field' do
      visit imprintables_path
      find("tr#imprintable_#{imprintable.id} a[data-action='edit']").click
      select_from_chosen(store.name, from: 'imprintable_sample_location_ids')
      find('#imprintable_sample_location_ids').native.send_keys(:return)
      find_button('Update Imprintable').click
      expect(page).to have_selector '.modal-content-success', text: 'Imprintable was successfully updated.'
      expect(current_path).to eq(edit_imprintable_path imprintable.id)
      expect(imprintable.reload.sample_location_ids.include? store.id).to be_truthy
    end
  end

  describe 'There is another imprintable' do
    let!(:coordinate) { create(:valid_imprintable) }
    scenario 'A user can utilize coordinate token input field', pending: true do
      visit imprintables_path
      find("tr#imprintable_#{imprintable.id} a[data-action='edit']").click
      select_from_chosen(coordinate.name, from: 'imprintable_coordinate_ids')
      find(:css, '#imprintable_coordinate_ids').native.send_keys(:return)
      find_button('Update Imprintable').click
      expect(page).to have_selector '.modal-content-success', text: 'Imprintable was successfully updated.'
      expect(imprintable.reload.coordinate_ids.include? coordinate.id).to be_truthy
    end
  end

  describe 'There is an imprint method' do
    let!(:imprint_method) { create(:valid_imprint_method) }
    scenario 'A user can utilize compatible imprint methods token input field', pending: true do
      visit imprintables_path
      find("tr#imprintable_#{imprintable.id} a[data-action='edit']").click
      fill_in 'Compatible Imprint Method IDs', with: imprint_method.name
      find('#imprintable_compatible_imprint_method_ids').native.send_keys(:return)
      find_button('Update Imprintable').click
      expect(page).to have_selector '.modal-content-success', text: 'Imprintable was successfully updated.'
      expect(imprintable.reload.compatible_imprint_method_ids.include? coordinate.id).to be_truthy
    end
  end


  scenario 'A user can edit an existing imprintable' do
    visit imprintables_path
    find("tr#imprintable_#{imprintable.id} a[data-action='edit']").click
    fill_in 'Special Considerations', :with => 'Edited Special Consideration'
    find_button('Update Imprintable').click
    expect(page).to have_selector '.modal-content-success', text: 'Imprintable was successfully updated.'
    expect(current_path).to eq(edit_imprintable_path imprintable.id)
    expect(imprintable.reload.special_considerations).to eq('Edited Special Consideration')
  end

  scenario 'A user can delete an existing imprintable', js: true do
    visit imprintables_path
    find("tr#imprintable_#{imprintable.id} a[data-action='destroy']").click
    page.driver.browser.switch_to.alert.accept
    wait_for_ajax
    expect(page).to have_selector '.modal-content-success', text: 'Imprintable was successfully destroyed.'
    expect(current_path).to eq(imprintables_path)
    expect(imprintable.reload.destroyed? ).to be_truthy
  end
end
