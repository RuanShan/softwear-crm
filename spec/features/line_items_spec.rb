require 'spec_helper'
include LineItemHelpers

feature 'Line Items management', line_item_spec: true, js: true do
  given!(:order) { create(:order_with_job) }
  given(:job) { order.jobs.first }

  given!(:white) { create(:valid_color, name: 'white') }
  given!(:shirt) { create(:valid_imprintable) }

  make_variants :white, :shirt, [:S, :M, :L], not: [:line_items, :job]

  given(:style) { shirt.style }
  given(:brand) { shirt.brand }

  given!(:valid_user) { create(:user) }
  before(:each) do
    login_as valid_user
  end

  given(:non_imprintable) { create(:non_imprintable_line_item, job_id: job.id) }

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

  scenario 'user can add a new imprintable line item', what: true do
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
    wait_for_ajax

    expect(LineItem.where(imprintable_variant_id: white_shirt_s.id)).to exist
    expect(LineItem.where(imprintable_variant_id: white_shirt_m.id)).to exist
    expect(LineItem.where(imprintable_variant_id: white_shirt_l.id)).to exist

    expect(page).to have_content shirt.style.name
    expect(page).to have_content shirt.style.catalog_no
    expect(page).to have_content shirt.description
  end

  scenario 'user cannot submit an imprintable line item without completing the form' do
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
    end

    find('#line-item-submit').click

    expect(page).to have_content 'error'
  end

  context 'editing a non-imprintable line item' do
    before(:each) do
      non_imprintable
      visit '/orders/1/edit#jobs'
      wait_for_ajax

      find('.line-item-button[title="Edit"]').click
      wait_for_ajax
      fill_in 'line_item[name]', with: 'New name!'

      find('.update-line-items').click
      wait_for_ajax
    end

    it 'is possible' do
      expect(LineItem.where name: 'New name!').to exist
    end

    scenario 'user can see the result' do
      expect(page).to have_content 'New name!'
    end

    scenario 'add line item button can still be pressed' do
      first('.add-line-item').click
      wait_for_ajax
      expect(page).to have_content 'New Line Item'
      expect(page).to have_css '#line-item-submit'
    end
  end

  scenario 'user sees errors when inputting bad data on standard line item edit' do
    non_imprintable
    visit '/orders/1/edit#jobs'
    wait_for_ajax

    find('.line-item-button[title="Edit"]').click
    wait_for_ajax
    fill_in 'line_item[quantity]', with: ''

    first('.update-line-items').click
    wait_for_ajax

    expect(page).to have_content 'error'
    expect(page).to have_content "Quantity can't be blank"
  end

  scenario 'user can remove imprintable line item', donow: true do
    ['s', 'm', 'l'].each do |s|
      job.line_items << send("white_shirt_#{s}_item")
    end
    visit '/orders/1/edit#jobs'
    wait_for_ajax

    expect(page).to have_content shirt.style.name

    first('.line-item-button[title="Delete"]').click
    wait_for_ajax
    sleep 2

    ['s', 'm', 'l'].each do |s|
      item = send("white_shirt_#{s}_item")
      expect(LineItem.where(id: item.id)).to_not exist
    end
    expect(page).to_not have_content shirt.style.name
  end

  scenario 'user can remove standard line item' do
    non_imprintable
    visit '/orders/1/edit#jobs'
    wait_for_ajax

    expect(page).to have_content non_imprintable.name

    first('.line-item-button[Title="Delete"]').click
    wait_for_ajax

    expect(LineItem.where(id: non_imprintable.id)).to_not exist
    expect(page).to_not have_content non_imprintable.name
  end
end