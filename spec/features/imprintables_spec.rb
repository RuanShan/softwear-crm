require 'spec_helper'
include ApplicationHelper

feature 'Imprintables management', imprintable_spec: true do
  given!(:valid_user) { create(:alternate_user) }
  before(:each) do
    login_as(valid_user)
  end

  let!(:imprintable) { create(:valid_imprintable)}

  scenario 'A user can see a list of imprintables' do
    visit root_path
    click_link 'imprintables_list_link'
    expect(current_path).to eq(imprintables_path)
    expect(page).to have_selector('.box-info')
  end

  scenario 'A user can create a new imprintable' do
    visit imprintables_path
    click_link('Add an Imprintable')
    fill_in 'Special considerations', :with => 'Special Consideration'
    page.find_by_id('imprintable_brand_id').find("option[value='#{imprintable.brand.id}']").click
    page.find_by_id('imprintable_style_id').find("option[value='#{imprintable.style.id}']").click
    find(:css, '#imprintable_flashable').click
    find(:css, '#imprintable_polyester').click
    click_button('Create Imprintable')
    expect(current_path).to eq(imprintables_path)
    expect(page).to have_selector '.modal-content-success', text: 'Imprintable was successfully created.'
    expect(Imprintable.find_by special_considerations: 'Special Consideration').to_not be_nil
  end

  scenario 'A user can edit an existing imprintable' do
    visit imprintables_path
    find("tr#imprintable_#{imprintable.id} a[data-action='edit']").click
    fill_in 'Special considerations', :with => 'Edited Special Consideration'
    click_button 'Update Imprintable'
    expect(current_path).to eq(edit_imprintable_path imprintable.id)
    expect(page).to have_selector '.modal-content-success', text: 'Imprintable was successfully updated.'
    expect(imprintable.reload.special_considerations).to eq('Edited Special Consideration')
  end

  scenario 'A user can delete an existing imprintable', js: true do
    visit imprintables_path
    find("tr#imprintable_#{imprintable.id} a[data-action='destroy']").click
    page.driver.browser.switch_to.alert.accept
    wait_for_ajax
    expect(current_path).to eq(imprintables_path)
    expect(page).to have_selector '.modal-content-success', text: 'Imprintable was successfully destroyed.'
    expect(imprintable.reload.destroyed? ).to be_truthy
  end

end