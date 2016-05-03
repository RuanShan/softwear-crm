require 'spec_helper'
include LineItemHelpers

feature 'Line Items management', slow: true, line_item_spec: true, js: true do
  given!(:variant) { create(:valid_imprintable_variant) }
  given!(:order) { create(:order_with_job) }
  given(:job) { order.jobs.first }

  given!(:white) { create(:valid_color, name: 'white') }
  given!(:shirt) { create(:valid_imprintable) }

  make_variants :white, :shirt, [:S, :M, :L, :XL, :XXL, :XXXL], not: [:line_items]

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
      choose 'Non-imprintable'
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
    choose 'Non-imprintable'
    sleep 1
    find('#line-item-submit').click
    sleep 1

    expect(page).to have_content "Unit price can't be blank"
    expect(page).to have_content "Quantity can't be blank"
  end

  context 'when the order has quotes associated with it', from_quote: true do
    given!(:quote_job) { create(:quote_job, line_items: [line_item_1, line_item_2]) }
    given(:quote) { quote_job.jobbable }

    given!(:line_item_1) { create(:imprintable_quote_line_item, tier: 3, imprintable_object: shirt) }
    given!(:line_item_2) { create(:imprintable_quote_line_item, tier: 3, imprintable_object: hat) }

    background :each do
      order.quotes << quote
    end

    scenario 'user can add a set of line items for an imprintable from a quote' do
      visit edit_order_path(order.id, anchor: 'jobs')
      sleep 1
      click_link 'Add Line Item'
      sleep 1
      expect(page).to have_content 'Add'

      within('.line-item-form') do
        sleep 1.5
        choose 'From quote'
        sleep 1.5
        check "line_items_#{line_item_1.id}_included"
        select2 'white', from: '.li-from-quote-select-color'
        find('.dec-price').set '2.30'
      end

      find('#line-item-submit').click
      sleep 1

      expect(LineItem.where(job_id: order.jobs.first.id, imprintable_object_id: white_shirt_s.id)).to exist
      expect(LineItem.where(job_id: order.jobs.first.id, imprintable_object_id: white_shirt_m.id)).to exist
      expect(LineItem.where(job_id: order.jobs.first.id, imprintable_object_id: white_shirt_l.id)).to exist

      expect(page).to have_content shirt.style_name
      expect(page).to have_content shirt.style_catalog_no
      expect(page).to have_content shirt.description

      expect(page).to_not have_selector '#lineItemModal'
    end
  end

  scenario 'user sees errors when inputting bad info for an imprintable line item, and they go away when fixed', story_818: true do
    line_item = white_shirt_m_item

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
      choose 'Imprintable'
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
    expect(find_field('decoration_price').value).to eq '2.30'
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
        choose 'Imprintable'
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
      expect(page).to have_css '.imprintable-line-item-input > label', text: send('size_'+s).display_value
    end
  end

  context 'Line Item pricing' do
    given!(:sizexl) { create(:valid_size, display_value: "XL", upcharge_group: "base_price") }
    given!(:sizexxl) { create(:valid_size, display_value: "2XL", upcharge_group: "xxl_price") }
    given!(:color) { create(:valid_color) }                      
    given!(:imprintable) { create(:valid_imprintable) }
    given!(:variant1) { create(:associated_imprintable_variant,
             imprintable_id: imprintable.id, size_id: sizexl.id,
             color_id: color.id) }
    given!(:variant2) { create(:associated_imprintable_variant,
             imprintable_id: imprintable.id, size_id: sizexxl.id,
             color_id: color.id) }
    
    scenario 'when adding line items the correct prices are displayed' do
      visit edit_order_path(order.id, anchor: "jobs")
      sleep 1
      click_link "Add Line Item"

      within('.line-item-form') do
        sleep 1.5
        choose 'Imprintable'
        sleep 1.5
        select imprintable.brand.name, from: 'Brand'
        sleep 1.5
        select imprintable.style_name, from: 'Imprintable'
        sleep 1.5
        select color.name, from: 'Color'
        sleep 1.5
        expect(page).to have_content imprintable.style_name
        expect(page).to have_content imprintable.style_description
        fill_in 'decoration_price', with: '2.30'
      end

      sleep 2

      find('#line-item-submit').click
      sleep 1

      #finds line items, XL and XXL
      xl_line_item_price = LineItem.find_by(imprintable_object_id: variant1.id).imprintable_price.to_f #9.99  
      xxl_line_item_price = LineItem.find_by(imprintable_object_id: variant2.id).imprintable_price.to_f#10.0

      #converts 10.0 to 10.00 
      xxl_line_item_price = ('%.2f' % xxl_line_item_price)

      within(all('.edit-line-item-row').last) do
        expect(page).to have_css "input[value='#{xl_line_item_price}']"
        expect(page).to have_css "input[value='#{xxl_line_item_price}']"
      end

      expect(xxl_line_item_price.to_f > xl_line_item_price).to be_truthy
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
      choose 'Imprintable'
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
      choose 'Imprintable'
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

      fill_in "line_item[#{non_imprintable.id}][name]", with: 'New name!'

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
    given(:variant) { white_shirt_s_item.imprintable_object }

    context 'with name/numbers present', name_number: true do
      given!(:imprint) { create(:imprint_with_name_number, job_id: job.id) }
      given(:name_number) { create(:name_number, imprintable_variant_id: variant.id, imprint_id: imprint.id) }

      # make_variants :white, :shirt, [:S, :M, :L, :XL, :XXL, :XXXL], not: [:line_items]
      background(:each) do
        white_shirt_s_item.update_column(:quantity, 1)
        white_shirt_m_item.update_column(:quantity, 0)
        white_shirt_l_item.update_column(:quantity, 0)
        white_shirt_xl_item.update_column(:quantity, 0)
        white_shirt_xxl_item.update_column(:quantity, 0)
        white_shirt_xxxl_item.update_column(:quantity, 0)
        name_number
      end

      scenario 'user sees warning when setting quantity greater than name/number amount', borke: true do 
        visit edit_order_path(order.id, anchor: 'jobs')
        sleep 2

        expect(page).to_not have_content "Quantities of name/numbers don't match"
        find("#line_item_#{white_shirt_s_item.id}_quantity").set 200
        sleep 1
        find('.update-line-items').click
        sleep 1
        expect(page).to have_content "Quantities of name/numbers don't match"
      end

      scenario 'user sees error when setting quantity less than name/number amount' do
        visit edit_order_path(order.id, anchor: 'jobs')
        sleep 1

        find("#line_item_#{white_shirt_s_item.id}_quantity").set 0
        sleep 1
        find('.update-line-items').click
        sleep 1

        expect(page).to have_content "(0) is less than the amount of name/numbers (1)"
        expect(white_shirt_s_item.reload.quantity).to_not eq 0
      end
    end
 
    scenario 'user sees updated quantity total' do 
      visit edit_order_path(order.id, anchor: 'jobs')
      sleep 1

      find("#line_item_#{white_shirt_s_item.id}_quantity").set 20
      sleep 1
      find('.update-line-items').click
      sleep 1
    
      expect(page).to have_css(".imprintable-line-item-total", text: "35")
    end

    scenario 'it does not create a ton of order activities', pa_spam: true do
      PublicActivity.with_tracking do
        expect do
          visit edit_order_path(order.id, anchor: 'jobs')
          sleep 1

          find("#line_item_#{white_shirt_s_item.id}_quantity").set 20
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
    fill_in "line_item[#{non_imprintable.id}][quantity]", with: ''

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
