require 'spec_helper'
include LineItemHelpers

feature 'Line Items management', line_item_spec: true, js: true do
  given!(:order) { create(:order_with_job) }
  given(:job) { order.jobs.first }

  given!(:white) { create(:valid_color, name: 'white') }
  given!(:shirt) { create(:valid_imprintable) }

  make_variants :white, :shirt, [:S, :M, :L]

  given(:style) { shirt.style }
  given(:brand) { shirt.brand }

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

  scenario 'user sees errors when inputting bad info for a standard line item' do
    visit '/orders/1/edit#jobs'
    wait_for_ajax

    form('.add-line-item').click
    wait_for_ajax

    within('.line-item-form') do
      choose 'No'
      wait_for_ajax

      find('.line-item-submit').click
      wait_for_ajax

      expect(page).to have_content "Unit price can't be blank"
      expect(page).to have_content "Quantity can't be blank"
    end
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
      select white.name, from: 'Color'
      expect(page).to have_content shirt.name
      expect(page).to have_content shirt.description

      click_button 'Add'
      wait_for_ajax
    end

    # expect(LineItem.where(imprintable_variant_id: imprintable_variant)).to exist
    expect()
    expect(page).to have_content 'success'
    expect(page).to have_content 'Test Item'
  end
end