require 'spec_helper'
include LineItemHelpers

feature 'Costs Management', js: true do
  given!(:order_1) { create(:order_with_job) }
  given!(:order_2) { create(:order_with_job) }
  given(:job_1)    { order_1.jobs.first }
  given(:job_2)    { order_2.jobs.first }

  given!(:white) { create(:valid_color, name: 'white') }
  given!(:shirt) { create(:valid_imprintable) }
  given!(:blue) { create(:valid_color, name: 'blue') }
  given!(:pants) { create(:valid_imprintable) }

  make_variants :white, :shirt, [:M, :S, :L], lazy: true
  make_variants :blue,  :pants, [:M, :S, :L], lazy: true

  background :each do
    job_1.line_items = [white_shirt_m_item, white_shirt_s_item, white_shirt_l_item]
    job_2.line_items = [blue_pants_m_item, blue_pants_s_item, blue_pants_l_item]
  end

  given!(:valid_user) { create(:user) }
  before(:each) do
    sign_in_as valid_user
  end

  scenario 'A user can add costs to line items that lack them' do
    visit costs_imprintables_path
    inputs = all('input[type=text]')

    inputs[0].set '12.00'
    inputs[1].set '10.00'

    click_button 'Submit'

    sleep ci? ? 3 : 1
    expect(LineItem.where(cost_amount: 12)).to exist
    expect(LineItem.where(cost_amount: 10)).to exist
  end

  context 'when there are existing costs for the shown variants' do
    given(:new_line_item_1) { create(:imprintable_line_item, imprintable_object: white_shirt_m, job: job_2) }
    given(:new_line_item_2) { create(:imprintable_line_item, imprintable_object: white_shirt_l, job: job_2) }

    background(:each) do
      white_shirt_m_item.update_column :cost_amount, 10
      white_shirt_l_item.update_column :cost_amount, 15

      white_shirt_m.update_column :last_cost_amount, 10.00
      white_shirt_l.update_column :last_cost_amount, 15.00
    end

    scenario 'the fields for line items of those variants already filled out' do
      new_line_item_1; new_line_item_2
      visit costs_imprintables_path

      expect(page).to have_css "input[type=text][value='10.0']"
      expect(page).to have_css "input[type=text][value='15.0']"
    end
  end

  feature 'on a specific order', order: true do
    given!(:order) { create(:order_with_job) }
    given(:job) { order.jobs.first }
    given!(:line_item) { create(:non_imprintable_line_item, job: job) }

    let!(:white) { create(:valid_color, name: 'white') }
    let!(:shirt) { create(:valid_imprintable) }
    make_variants :white, :shirt, [:M, :S, :L]

    scenario 'a user can add costs directly to the order', order_cost: true do
      visit edit_order_path(order, anchor: 'costs')
      sleep 1

      click_link '+ Order Cost'
      all('.order-costs span.select2-container').first.click
      all('.select2-results__option').first.click
      fill_in 'Description', with: 'moni'
      fill_in 'Time', with: '5'
      click_button 'Update Order'

      sleep 1

      expect(order.reload.costs.where(time: 5, type: 'Salesperson')).to exist
    end

    scenario 'a user can add costs to standard line items' do
      visit edit_order_path(order, anchor: 'costs')
      sleep 1

      fill_in 'Cost', with: '10.50'
      click_button 'Update Order'

      sleep 1

      expect(line_item.reload.cost_amount.to_f).to eq 10.50
      expect(page).to have_content 'Total Cost: $10.50'
    end

    scenario 'a user can add costs to imprintable line items' do
      visit edit_order_path(order, anchor: 'costs')
      sleep 1

      find(".line-item-#{white_shirt_s_item.id}-cost input[type=text]").set 20.15
      find(".line-item-#{white_shirt_m_item.id}-cost input[type=text]").set 5.15
      find(".line-item-#{white_shirt_l_item.id}-cost input[type=text]").set 5.00
      click_button 'Update Order'

      sleep 1

      expect(white_shirt_s_item.reload.cost_amount).to_not be_nil
      expect(white_shirt_m_item.reload.cost_amount).to_not be_nil
      expect(white_shirt_l_item.reload.cost_amount).to_not be_nil

      expect(white_shirt_s_item.cost_amount.to_f).to eq 20.15
      expect(white_shirt_m_item.cost_amount.to_f).to eq 5.15
      expect(white_shirt_l_item.cost_amount.to_f).to eq 5.00

      expect(page).to have_content 'Total Cost: $30.30'
    end

    scenario 'a user can remove an order cost' do
      order.costs.create(type: 'Test Cost', description: ':(', amount: 10.0)

      visit edit_order_path(order, anchor: 'costs')
      sleep 1

      expect(page).to have_content 'Total Cost: $10.00'
      click_link '- Cost'
      click_button 'Update Order'
      sleep 1
      expect(page).to have_content 'Total Cost: $0.00'
    end
  end
end
