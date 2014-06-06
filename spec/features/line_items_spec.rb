require 'spec_helper'
include LineItemHelpers

feature 'Line Items management', line_item_spec: true, js: true do
  given!(:order) { create(:order_with_job) }
  given(:job) { order.jobs.first }

  given!(:white) { create(:valid_color, name: 'white') }
  given!(:shirt) { create(:valid_imprintable) }

  make_variants :white, :shirt, [:S, :M, :L], not: [:line_items, :jobs]

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
    end

    find('#line-item-submit').click
    sleep 3

    expect(LineItem.where(name: 'New Item')).to exist
    expect(page).to have_content 'success'
    expect(page).to have_content 'New Item'
  end

  scenario 'user sees errors when inputting bad info for a standard line item' do
    visit '/orders/1/edit#jobs'
    wait_for_ajax

    first('.add-line-item').click
    wait_for_ajax
    choose 'No'
    wait_for_ajax
    find('#line-item-submit').click
    wait_for_ajax

    expect(page).to have_content "Unit price can't be blank"
    expect(page).to have_content "Quantity can't be blank"
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
      wait_for_ajax
      select style.name, from: 'Style'
      wait_for_ajax
      select white.name, from: 'Color'
      wait_for_ajax
      expect(page).to have_content shirt.style.name
      expect(page).to have_content shirt.style.description
    end

    find('#line-item-submit').click

    expect(LineItem.where(imprintable_variant_id: white_shirt_s.id)).to exist
    expect(LineItem.where(imprintable_variant_id: white_shirt_m.id)).to exist
    expect(LineItem.where(imprintable_variant_id: white_shirt_l.id)).to exist

    expect(page).to have_content 'success'
    expect(page).to have_content white_shirt_s.name
    expect(page).to have_content white_shirt_s.description
  end
end