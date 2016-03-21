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
    sign_in_as valid_user
  end

  given(:non_imprintable) { create(:non_imprintable_line_item, line_itemable_id: job.id, line_itemable_type: 'Job') }

  scenario 'user can add a new non-imprintable line item' do
    visit edit_order_path(order.id, anchor: 'jobs')
    sleep 1
    first('.add-line-item').click
    sleep 1
    expect(page).to have_content 'Add'

    within('.line-item-form') do
      choose 'No'
      sleep 1
      fill_in 'Name', with: 'New Item'
      fill_in 'Description', with: 'Insert deeply descriptive text here'
      fill_in 'Quantity', with: '3'
      fill_in 'Unit price', with: '5.00'
    end

    sleep 1
    find('#line-item-submit').click
    sleep 1

    expect(LineItem.where(name: 'New Item')).to exist
    expect(page).to have_content 'New Item'
  end

  scenario 'user sees errors when inputting bad info for a standard line item' do
    visit edit_order_path(order.id, anchor: 'jobs')
    sleep 1

    first('.add-line-item').click
    sleep 1
    choose 'No'
    sleep 1
    find('#line-item-submit').click
    sleep 1

    expect(page).to have_content "Unit price can't be blank"
    expect(page).to have_content "Quantity can't be blank"
  end

  scenario 'user sees errors when inputting bad info for an imprintable line item, and they go away when fixed', story_818: true do
    line_item = LineItem.create_imprintables(job, shirt, white).sample

    visit edit_order_path(order.id, anchor: 'jobs')
    sleep 1

    find("#line_item_#{line_item.id}_quantity").set(-4)
    sleep 1
    find('.update-line-items').click
    sleep 1

    first('[data-dismiss="modal"]').click

    expect(page).to have_content "Quantity cannot be negative"
    expect(line_item.reload.quantity).to_not eq(-4)

    find("#line_item_#{line_item.id}_quantity").set 2
    sleep 1
    find('.update-line-items').click
    sleep 1

    expect(page).to_not have_content "Quantity can't be negative"

    expect(line_item.reload.quantity).to eq 2
  end

  scenario 'user can add a new imprintable line item', story_692: true do
    visit edit_order_path(order.id, anchor: 'jobs')
    sleep 1
    click_link 'Add Line Item'
    sleep 1
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
      fill_in 'decoration_price', with: '2.30'
    end

    sleep 1
    sleep 1
    find('#line-item-submit').click
    sleep 1
    expect(LineItem.where(imprintable_object_id: white_shirt_s.id)).to exist
    expect(LineItem.where(imprintable_object_id: white_shirt_m.id)).to exist
    expect(LineItem.where(imprintable_object_id: white_shirt_l.id)).to exist

    expect(page).to have_content shirt.style_name
    expect(page).to have_content shirt.style_catalog_no
    expect(page).to have_content shirt.description
    expect(page).to have_css 'input[value="2.30"]'
  end

  scenario 'user cannot add duplicate imprintable line items' do
    2.times do
      visit edit_order_path(order.id, anchor: 'jobs')
      sleep 1

      first('.add-line-item').click
      sleep 1
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

      sleep 1
      find('#line-item-submit').click
      sleep 1.5
    end

    ['s', 'm', 'l'].each do |s|
      expect(page).to have_css '.imprintable-line-item-input > label', text: send('size_'+s).display_value, count: 1
    end
  end

  scenario 'user cannot submit an imprintable line item without completing the form' do
    visit edit_order_path(order.id, anchor: 'jobs')
    sleep 1

    first('.add-line-item').click
    sleep 1
    expect(page).to have_content 'Add'

    within('.line-item-form') do
      sleep(1)
      choose 'Yes'
      sleep 1
      select brand.name, from: 'Brand'
      sleep 1
    end

    find('#line-item-submit').click

    expect(page).to have_content 'error'
  end

  scenario 'creating an imprintable line item, user can switch a lower-level select and it will reset the higher levels' do
    hat_brand;
    visit edit_order_path(order.id, anchor: 'jobs')
    sleep 1

    first('.add-line-item').click
    sleep 1
    expect(page).to have_content 'Add'

    within('.line-item-form') do
      choose 'Yes'
      sleep 1
      select hat_brand.name, from: 'Brand'
      sleep 1
      expect(page).to have_content hat.style_name
      select brand.name, from: 'Brand'
      sleep 1
      expect(page).to_not have_content hat.style_name
      expect(page).to have_content shirt.style_name
    end
  end

  context 'editing a non-imprintable line item' do
    background(:each) do
      non_imprintable
      visit edit_order_path(order.id, anchor: 'jobs')
      sleep 1

      find('.line-item-button[title="Edit"]').click
      sleep 1

      fill_in "line_item[#{non_imprintable.id}[name]]", with: 'New name!'

      find('.update-line-items').click
      sleep 1
    end

    scenario 'is possible' do
      expect(LineItem.where name: 'New name!').to exist
    end

    scenario 'user can see the result' do
      expect(page).to have_content 'New name!'
    end

    scenario 'add line item button can still be pressed' do
      first('.add-line-item').click
      sleep 1
      expect(page).to have_content 'New Line Item'
      expect(page).to have_css '#line-item-submit'
    end
  end

  context 'editing an imprintable line item' do 
    let!(:line_item) { LineItem.create_imprintables(job, shirt, white).sample }
 
    scenario 'user sees updated quantity total' do 
      visit edit_order_path(order.id, anchor: 'jobs')
      sleep 1

      find("#line_item_#{line_item.id}_quantity").set 20
      sleep 1
      find('.update-line-items').click
      sleep 1
    
      expect(page).to have_css(".imprintable-line-item-total", text: "20")
    end

    scenario 'it does not create a ton of order activities', pa_spam: true do
      PublicActivity.with_tracking do
        expect do
          visit edit_order_path(order.id, anchor: 'jobs')
          sleep 1

          find("#line_item_#{line_item.id}_quantity").set 20
          sleep 1
          find('.update-line-items').click
          sleep 1
        end
          .to_not change { order.activities.reload.size }
      end
    end
  end

  scenario 'user sees errors when inputting bad data on standard line item edit' do
    non_imprintable
    visit edit_order_path(order.id, anchor: 'jobs')
    sleep 1

    find('.line-item-button[title="Edit"]').click
    sleep 1
    fill_in "line_item[#{non_imprintable.id}[quantity]]", with: ''

    first('.update-line-items').click
    sleep 1

    expect(page).to have_content "Quantity can't be blank"
  end

  scenario 'user can remove imprintable line item' do
    ['s', 'm', 'l'].each do |s|
      job.line_items << send("white_shirt_#{s}_item")
    end
    visit edit_order_path(order.id, anchor: 'jobs')
    sleep 1

    expect(page).to have_content shirt.style_name

    first('a[title="Delete"]').click
    sleep 2

    ['s', 'm', 'l'].each do |s|
      item = send("white_shirt_#{s}_item")
      expect(LineItem.where(id: item.id)).to_not exist
    end
    expect(page).to_not have_content shirt.style_name
  end

  scenario 'user can remove standard line item' do
    non_imprintable
    visit edit_order_path(order.id, anchor: 'jobs')
    sleep 1

    expect(page).to have_content non_imprintable.name

    first('.line-item-button[Title="Delete"]').click
    sleep 1

    expect(LineItem.where(id: non_imprintable.id)).to_not exist
    expect(page).to_not have_content non_imprintable.name
  end
  
  context 'order has two jobs with the same imprintable line_item', story_971: true  do
    
    given(:job_2) { create(:job, jobbable: order) }
    make_variants :white, :shirt, [:S, :M, :L], not: [:line_items, :job_2]
    
    scenario 'removing the line_item from the second job hides the correct line item' do
      
      ['s', 'm', 'l'].each do |s|
        job.line_items << send("white_shirt_#{s}_item")
      end
      
      job.line_items.each do |li_old|
        li_new = li_old.dup
        job_2.line_items << li_new
      end
      
      deleted_imprintable_id = job_2.line_items.first.imprintable.id
      
      visit edit_order_path(order.id, anchor: 'jobs')
      expect(page).to have_selector("[data-job-id='#{job.id}'] [data-imprintable-id='#{job.line_items.first.imprintable.id}']")
      expect(page).to have_selector("[data-job-id='#{job_2.id}'] [data-imprintable-id='#{deleted_imprintable_id}']")
      sleep 1
      
      within("[data-job-id='#{job_2.id}']") do 
        find('a[title="Delete"]').click
        sleep 2
      end

      expect(page).to have_selector("[data-job-id='#{job.id}'] [data-imprintable-id='#{job.line_items.first.imprintable.id}']")
      expect(page).to_not have_selector("[data-job-id='#{job_2.id}'] [data-imprintable-id='#{deleted_imprintable_id}']")
    end
  end
end
