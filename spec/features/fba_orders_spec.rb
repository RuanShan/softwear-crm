require 'spec_helper'

feature 'FBA Order management', fba_spec: true, story_103: true do
  given!(:valid_user) { create :user }
  background(:each) { login_as valid_user }

  given(:packing_slip_path) { "#{Rails.root}spec/fixtures/fba/TestPackingSlip.txt" }

  context 'given valid imprintables, sizes, and colors' do
    given!(:size_s) { create :valid_size, sku: '02' }
    given!(:size_m) { create :valid_size, sku: '03' }
    given!(:size_l) { create :valid_size, sku: '04' }
    given!(:size_xl) { create :valid_size, sku: '05' }
    given!(:color) { create :valid_color, sku: '000' }
    given!(:imprintable) { create :valid_imprintable, sku: '0705' }

    scenario 'user can view an index of FBA orders from the sidebar' do
      visit root_path
      unhide_dashboard
      click_link 'Orders'
      click_link 'FBA'
    end
  end

  describe 'creation' do
    scenario 'user can create a new FBA order' do
      visit fba_orders_path
      click_link 'New FBA Order'

      fill_in 'Name', with: 'Test FBA'
      fill_in 'Deadline', with: 'Feb 04, 2015, 12:00 PM'
      select 'Test Store', from: 'Store'

      click_button 'Next'

      fill_in 'Packing Slips', with: packing_slip_path

      click_button 'Next'
      click_button 'Process'

      wait_for_ajax

      expect(page).to have_content 'Success'
      expect(Order.fba).to exist
    end

    context 'given valid imprintable, color, but missing one size' do
      given!(:other_size_s) { create :valid_size, sku: '10' }
      given!(:size_m) { create :valid_size, sku: '03' }
      given!(:size_l) { create :valid_size, sku: '04' }
      given!(:size_xl) { create :valid_size, sku: '05' }
      given!(:color) { create :valid_color, sku: '000' }
      given!(:imprintable) { create :valid_imprintable, sku: '0705' }

      scenario 'user can choose a size to replace the missing one' do
        visit fba_orders_path
        click_link 'New FBA Order'

        fill_in 'Name', with: 'Test FBA'
        fill_in 'Deadline', with: 'Feb 04, 2015, 12:00 PM'
        select 'Test Store', from: 'Store'

        click_button 'Next'

        fill_in 'Packing Slips', with: packing_slip_path

        click_button 'Next'
        click_button 'Process'
        wait_for_ajax

        expect(page).to have_content %(
          Packing slip FBA237FK5S Couldn't find size with sku '02'
        )
        expect(page).to have_content "Choose a size to replace it"

        select other_size_s.name, from: 'fba237fk5s_other_sizes'

        click_button 'Try Again'
        wait_for_ajax

        expect(page).to have_content 'Success'
        expect(Order.fba).to exist
      end

      scenario 'user can say whatever can just generate the order' do
        visit fba_orders_path
        click_link 'New FBA Order'

        fill_in 'Name', with: 'Test FBA'
        fill_in 'Deadline', with: 'Feb 04, 2015, 12:00 PM'
        select 'Test Store', from: 'Store'

        click_button 'Next'

        fill_in 'Packing Slips', with: packing_slip_path

        click_button 'Next'
        click_button 'Process'
        wait_for_ajax

        expect(page).to have_content %(
          Packing slip FBA237FK5S Couldn't find size with sku '02'
        )

        click_button 'Create Anyway'
        wait_for_ajax

        expect(page).to have_content 'Success'
        expect(Order.fba).to exist
      end
    end
  end
end