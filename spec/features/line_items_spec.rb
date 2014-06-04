require 'spec_helper'

feature 'Line Items managements', line_item_spec: true, js: true do
  given!(:order) { create(:order_with_job) }
  given(:job) { order.jobs.first }
  given!(:color) { create :valid_color }

  given!(:imprintable_variant) { create :valid_imprintable_variant }
  given(:imprintable) { imprintable_variant.imprintable }

  given(:brand) { imprintable_variant.imprintable.brand }
  given(:style) { imprintable_variant.style }

  given!(:valid_user) { create(:user) }
  before(:each) do
    login_as valid_user
  end

  scenario 'user can add a new non-imprintable line item' do
    visit '/orders/1/edit#jobs'
    wait_for_ajax

    first('.add-line-item').click
    wait_for_ajax
    expect(page).to have_content 'Add'

    within('.line-item-form') do
      choose 'No'
      wait_for_ajax
      fill_in 'Name', with: 'New Item'
      fill_in 'Description', with: 'Insert deeply descriptive text here'
      fill_in 'Quantity', with: '3'
      fill_in 'Unit price', with: '5.00'

      find('.line-item-submit').click
      wait_for_ajax
    end

    expect(LineItem.where(name: 'New Item')).to exist
    expect(page).to have_content 'success'
    expect(page).to have_content 'New Item'
  end

  scenario 'user can add a new imprintable line item' do
    visit '/orders/1/edit#jobs'
    wait_for_ajax

    first('.add-line-item').click
    wait_for_ajax
    expect(page).to have_content 'Add'

    within('.line-item-form') do
      choose 'Yes'
      wait_for_ajax
      select brand.name, from: 'Brand'
      select style.name, from: 'Style'
      select color.name, from: 'Color'
      expect(page).to have_content imprintable.name
      expect(page).to have_content imprintable.description

      click_button 'Add'
      wait_for_ajax
    end

    expect(LineItem.where(imprintable_variant_id: imprintable_variant)).to exist
    expect(page).to have_content 'success'
    expect(page).to have_content 'Test Item'
  end
end