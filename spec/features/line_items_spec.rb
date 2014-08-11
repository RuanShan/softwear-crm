require 'spec_helper'
include LineItemHelpers

feature 'Line Items management', line_item_spec: true, js: true do
  given!(:order) { create(:order_with_job) }
  given(:job) { order.jobs.first }

  given!(:white) { create(:valid_color, name: 'white') }
  given!(:shirt) { create(:valid_imprintable) }

  make_variants :white, :shirt, [:S, :M, :L], not: [:line_items, :job]

  given(:brand) { shirt.brand }

  given(:hat) { create(:valid_imprintable) }
  given(:hat_brand) { hat.brand }

  given!(:valid_user) { create(:user) }
  before(:each) do
    login_as valid_user
  end

  given(:non_imprintable) { create(:non_imprintable_line_item, line_itemable_id: job.id, line_itemable_type: 'Job') }

  scenario 'user can add a new non-imprintable line item' do
    visit edit_order_path(1, anchor: 'jobs')
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

    wait_for_ajax
    find('#line-item-submit').click
    sleep 3

    expect(LineItem.where(name: 'New Item')).to exist
    expect(page).to have_content 'New Item'
  end

  scenario 'user sees errors when inputting bad info for a standard line item' do
    visit edit_order_path(1, anchor: 'jobs')
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
    visit edit_order_path(1, anchor: 'jobs')
    wait_for_ajax

    first('.add-line-item').click
    wait_for_ajax
    expect(page).to have_content 'Add'

    within('.line-item-form') do
      sleep 1.5
      choose 'Yes'
      sleep 1.5
      select brand.name, from: 'Brand'
      sleep 1.5
      select shirt.style_name, from: 'Imprintable'
      sleep 1.5
      select white.name, from: 'Color'
      sleep 1.5
      expect(page).to have_content shirt.style_name
      expect(page).to have_content shirt.style_description
      fill_in 'base_unit_price', with: '2.30'
    end

    wait_for_ajax
    find('#line-item-submit').click
    sleep 3

    expect(LineItem.where(imprintable_variant_id: white_shirt_s.id)).to exist
    expect(LineItem.where(imprintable_variant_id: white_shirt_m.id)).to exist
    expect(LineItem.where(imprintable_variant_id: white_shirt_l.id)).to exist

    expect(page).to have_content shirt.style_name
    expect(page).to have_content shirt.style_catalog_no
    expect(page).to have_content shirt.description
    expect(page).to have_css 'input[value="2.30"]'
  end

  scenario 'user cannot add duplicate imprintable line items' do
    2.times do
      visit edit_order_path(1, anchor: 'jobs')
      wait_for_ajax

      first('.add-line-item').click
      wait_for_ajax
      expect(page).to have_content 'Add'

      within('.line-item-form') do
        sleep 1.5
        choose 'Yes'
        sleep 1.5
        select brand.name, from: 'Brand'
        sleep 1.5
        select shirt.style_name, from: 'Imprintable'
        sleep 1.5
        select white.name, from: 'Color'
        sleep 1.5
      end

      wait_for_ajax
      find('#line-item-submit').click
      sleep 1.5
    end

    ['s', 'm', 'l'].each do |s|
      expect(page).to have_css '.imprintable-line-item-input > label', text: send('size_'+s).display_value, count: 1
    end
  end

  it 'user cannot submit an imprintable line item without completing the form', pending: 'Need to review with Nigel'  do
    visit edit_order_path(1, anchor: 'jobs')
    wait_for_ajax

    first('.add-line-item').click
    wait_for_ajax
    expect(page).to have_content 'Add'

    within('.line-item-form') do
      sleep(1)
      choose 'Yes'
      wait_for_ajax
      select brand.name, from: 'Brand'
      wait_for_ajax
    end

    find('#line-item-submit').click

    expect(page).to have_content 'error'
  end

  scenario 'creating an imprintable line item, user can switch a lower-level select and it will reset the higher levels' do
    hat_brand;
    visit edit_order_path(1, anchor: 'jobs')
    wait_for_ajax

    first('.add-line-item').click
    wait_for_ajax
    expect(page).to have_content 'Add'

    within('.line-item-form') do
      choose 'Yes'
      wait_for_ajax
      select hat_brand.name, from: 'Brand'
      wait_for_ajax
      expect(page).to have_content hat.style_name
      select brand.name, from: 'Brand'
      wait_for_ajax
      expect(page).to_not have_content hat.style_name
      expect(page).to have_content shirt.style_name
    end
  end

  context 'editing a non-imprintable line item' do
    before(:each) do
      non_imprintable
      visit edit_order_path(1, anchor: 'jobs')
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
    visit edit_order_path(1, anchor: 'jobs')
    wait_for_ajax

    find('.line-item-button[title="Edit"]').click
    wait_for_ajax
    fill_in 'line_item[quantity]', with: ''

    first('.update-line-items').click
    wait_for_ajax

    expect(page).to have_content 'error'
    expect(page).to have_content "Quantity can't be blank"
  end

  scenario 'user can remove imprintable line item' do
    ['s', 'm', 'l'].each do |s|
      job.line_items << send("white_shirt_#{s}_item")
    end
    visit edit_order_path(1, anchor: 'jobs')
    wait_for_ajax

    expect(page).to have_content shirt.style_name

    first('.line-item-button[title="Delete"]').click
    wait_for_ajax
    sleep 2

    ['s', 'm', 'l'].each do |s|
      item = send("white_shirt_#{s}_item")
      expect(LineItem.where(id: item.id)).to_not exist
    end
    expect(page).to_not have_content shirt.style_name
  end

  scenario 'user can remove standard line item' do
    non_imprintable
    visit edit_order_path(1, anchor: 'jobs')
    wait_for_ajax

    expect(page).to have_content non_imprintable.name

    first('.line-item-button[Title="Delete"]').click
    wait_for_ajax

    expect(LineItem.where(id: non_imprintable.id)).to_not exist
    expect(page).to_not have_content non_imprintable.name
  end
end