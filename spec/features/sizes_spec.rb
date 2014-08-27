require 'spec_helper'
include ApplicationHelper

feature 'sizes management', size_spec: true do

  given!(:valid_user) { create(:alternate_user) }
  background(:each) { login_as(valid_user) }

  given!(:size) do
    create(:valid_size)
    create(:valid_size)
  end

  scenario 'A user can see a list of sizes' do
    visit root_path
    click_link 'sizes_list_link'

    expect(current_path).to eq(sizes_path)
    expect(page).to have_selector('.box-info')
  end

  scenario 'A user can create a new size' do
    visit sizes_path
    click_link('Add a Size')

    fill_in 'size_name', with: 'Sample Name'
    fill_in 'size_sku', with: '99'
    click_button('Create Size')

    expect(page).to have_selector '.modal-content-success', text: 'Size was successfully created.'
    expect(Size.find_by name: 'Sample Name').to_not be_nil
  end

  scenario 'A user can edit an existing size' do
    visit edit_size_path size.id
    fill_in 'size_name', with: 'Edited size Name'
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

  scenario 'A user can reorganize a row', js: true, pending: 'Doesnt work after moving file into vendor' do
    visit sizes_path
    first_child = find(:css, '.size_row:first-child')
    page.execute_script '
      $(document).ready(function() {
        $.getScript("/home/nick/RubymineProjects/softwear-crm/vendor/assets/javascripts/jquery/jquery.simulate.drag-sortable.js", function() {
          $(".size_row:first-child").simulateDragSortable({ move: 1});
        });
      });
    '
    wait_for_ajax
    expect(find(:css, '.size_row:nth-child(2)')).to eq(first_child)
  end
end
