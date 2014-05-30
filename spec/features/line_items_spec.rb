require 'spec_helper'

feature 'Line Items managements', line_item_spec: true do
  given!(:order) { create(:order_with_job) }
  given(:job) { order.jobs.first }

  given!(:valid_user) { create(:user) }
  before(:each) do
    login_as valid_user
  end

  scenario 'user can add a new non-imprintable line item' do
    visit '/orders/1/edit#jobs'
    wait_for_ajax

    click_button 'Add Line Item'
    wait_for_ajax
    expect(page).to have_content 'Add a Line Item'

    within('.line_item_form') do
      check 'No'
      wait_for_ajax
      fill_in 'Name', with: 'New Item'
      fill_in 'Description', with: 'Insert deeply descriptive text here'
      fill_in 'Quantity', with: '3'
      fill_in 'Unit Price', with: '5.00'
      click_button 'Add'
      wait_for_ajax

      expect(LineItem.where(name: 'New Item')).to exist
    end
  end

  scenario 'user can add a new imprintable line item' do
    visit '/orders/1/edit#jobs'
    wait_for_ajax

    click_button 'Add Line Item'
    wait_for_ajax
    expect(page).to have_content 'Add a Line Item'

    within('.line_item_form') do
      check 'Yes'
      wait_for_ajax
      
    end
  end
end