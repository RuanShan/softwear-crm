require 'spec_helper'
include ApplicationHelper

feature 'sizes management' do

  let!(:size) { create(:valid_size)}


  scenario 'A user can see a list of sizes' do
    visit root_path
    click_link 'sizes_list_link'
    expect(current_path).to eq(sizes_path)
    expect(page).to have_selector('.box-info')
  end

  scenario 'A user can create a new size' do
    visit sizes_path
    click_link('Add a Size')
    fill_in 'size_name', :with => 'Sample Name'
    fill_in 'size_sku', :with => '1234'
    fill_in 'size_sort_order', :with => '1'
    click_button('Create Size')
    expect(page).to have_selector '.modal-content-success', text: 'Size was successfully created.'
    expect(Size.find_by name: 'Sample Name').to_not be_nil
  end

  scenario 'A user can edit an existing size' do
    visit sizes_path
    find("tr#size_#{size.id} a[data-action='edit']").click
    fill_in 'size_name', :with => 'Edited size Name'
    click_button 'Update Size'
    expect(current_path).to eq(sizes_path)
    expect(page).to have_selector '.modal-content-success', text: 'Size was successfully updated.'
    expect(size.reload.name).to eq('Edited size Name')
  end

  scenario 'A user can delete an existing size', js: true do
    visit sizes_path
    find("tr#size_#{size.id} a[data-action='destroy']").click
    page.driver.browser.switch_to.alert.accept
    wait_for_ajax
    expect(current_path).to eq(sizes_path)
    expect(page).to have_selector '.modal-content-success', text: 'Size was successfully destroyed.'
    expect(size.reload.destroyed? ).to be_truthy
  end

  scenario 'A user can sort a column in ascending order', js: true do
    visit sizes_path
    first('#sizes_list thead tr th').click
    wait_for_ajax
    expect(current_path).to eq(sizes_path)
    expect(page).to have_css("*[data-sorted-direction='ascending']")
  end

  scenario 'A user can sort a column in descending order', js: true do
    visit sizes_path
    first('#sizes_list thead tr th').click
    first('#sizes_list thead tr th').click
    wait_for_ajax
    expect(current_path).to eq(sizes_path)
    expect(page).to have_css("*[data-sorted-direction='descending']")
  end
end