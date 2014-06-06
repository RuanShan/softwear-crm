require 'spec_helper'
include ApplicationHelper

feature 'Imprint Method Features' do
  given!(:valid_user) { create(:alternate_user) }
  before(:each) do
    login_as(valid_user)
  end

  let!(:imprint_method) { create(:valid_imprint_method)}

  scenario 'A user can add an imprint method' , js: true, wip: true do
    visit imprint_methods_path
    click_link 'Add an Imprint Method'
    fill_in 'Name', with: 'New Imprint Method Name'
    fill_in 'Production name', with: 'New Production Name'
    click_link 'Add Ink color'
    find(:css, "input[id^='imprint_method_ink_colors_attributes_'][id$='_name']").set('Red')
    # find("input#id^$='imprint_method_ink_colors_attributes_").set('Red')
    click_button 'Create Imprint Method'
    expect(ImprintMethod.where(name: 'New Imprint Method Name')).to exist
    expect(page).to have_selector('#flash_notice', text: 'Imprint method was successfully created.')
  end

  scenario 'A user can delete an imprint method feature', js: true do
    visit imprint_methods_path
    find("tr#imprint_method_#{imprint_method.id} a[data-action='destroy']").click
    page.driver.browser.switch_to.alert.accept
    wait_for_ajax
    expect( imprint_method.reload.destroyed? ).to be_truthy
  end

  scenario 'A user can edit an imprint method feature' do
    visit imprint_methods_path
    find("tr#imprint_method_#{imprint_method.id} a[data-action='edit']").click
    fill_in 'Name', with: 'Edited Imprint Method Name'
    click_button 'Update Imprint Method'
    expect(imprint_method.reload.name).to eq('Edited Imprint Method Name')
    expect(page).to have_selector('#flash_notice', text: 'Imprint method was successfully updated.')
  end

  scenario 'A user can view a list of imprint methods' do
    visit root_path
    click_link 'Configuration'
    click_link 'Imprint Methods'
    expect(page).to have_css("tr##{model_table_row_id(imprint_method)}")
  end

end