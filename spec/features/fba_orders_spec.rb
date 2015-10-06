require 'spec_helper'

feature 'FBA Order management', fba_spec: true, story_103: true, js: true do
  given!(:valid_user) { create :user }
  background(:each) { login_as valid_user }

  given(:packing_slip_path) { "#{Rails.root}/spec/fixtures/fba/TestPackingSlip.txt" }

  # Dashboard doesn't even work on ci
  unless ci?
    scenario 'user can view an index of FBA orders from the sidebar' do
      visit root_path
      unhide_dashboard
      click_link 'Orders'
      click_link 'FBA'
    end
  end

  context 'given valid imprintables, sizes, and colors' do
    given!(:size_s) { create :valid_size, sku: '02' }
    given!(:size_m) { create :valid_size, sku: '03' }
    given!(:size_l) { create :valid_size, sku: '04' }
    given!(:size_xl) { create :valid_size, sku: '05' }
    given!(:color) { create :valid_color, sku: '000' }
    given!(:imprintable) { create :valid_imprintable, sku: '0705' }

    [:size_s, :size_m, :size_l, :size_xl].each do |size|
      before :each do
        create(
          :blank_imprintable_variant,
          size_id: send(size).id,
          color_id: color.id,
          imprintable_id: imprintable.id
        )
      end
    end

    describe 'creation' do
      before(:each) do
        Capybara.ignore_hidden_elements = false
      end

      after(:each) do
        Capybara.ignore_hidden_elements = true
      end

      scenario 'user can create a new FBA order', create: true do
        visit fba_orders_path
        click_link 'New FBA Order'

        fill_in 'Name', with: 'Test FBA'
        fill_in 'Deadline', with: 'Feb 04, 2015, 12:00 PM'

        click_button 'Next'
        sleep 0.2

        find('#js-upload-packing-slips-button').click
        wait_for_ajax
        attach_file 'packing_slips_', packing_slip_path

        sleep 1

        expect(page).to have_content 'Job and line items will be generated'

        click_button 'Next'
        sleep 0.5
        all('input[value="Submit"]').first.click

        sleep 2 if ci?
        expect(Order.fba.where(name: 'Test FBA')).to exist
        order = Order.fba.find_by(name: 'Test FBA')
        expect(order.jobs.count).to eq 1

        expect(order.jobs.first.line_items.count).to eq 4
        expect(page).to have_content 'Test FBA'
      end

      context 'when a color sku is mismatched' do
        before(:each) do
          color.update_attributes sku: '123'
        end

        scenario 'user can choose a different color', color: true do
          visit fba_orders_path
          click_link 'New FBA Order'

          fill_in 'Name', with: 'Test FBA'
          fill_in 'Deadline', with: 'Feb 04, 2015, 12:00 PM'

          click_button 'Next'

          attach_file 'packing_slips_', packing_slip_path
          wait_for_ajax

          expect(page).to have_content %(Unable to find color with sku '000')

          select color.name, from: 'colors'
          click_link 'Retry'

          wait_for_ajax

          expect(page).to have_content 'Job and line items will be generated'

          click_button 'Next'
          sleep 0.2
          all('input[value="Submit"]').first.click

          sleep 2 if ci?
          expect(Order.fba.where(name: 'Test FBA')).to exist
          order = Order.fba.find_by(name: 'Test FBA')
          expect(order.jobs.count).to eq 1

          expect(order.jobs.first.line_items.count).to eq 4
          expect(page).to have_content 'Test FBA'
        end
      end
    end
  end

  context 'given valid imprintable, color, but missing one size', size: true do
    before(:each) do
      Capybara.ignore_hidden_elements = false
    end

    after(:each) do
      Capybara.ignore_hidden_elements = true
    end

    given!(:other_size_s) { create :valid_size, sku: '10' }
    given!(:size_m) { create :valid_size, sku: '03' }
    given!(:size_l) { create :valid_size, sku: '04' }
    given!(:size_xl) { create :valid_size, sku: '05' }
    given!(:color) { create :valid_color, sku: '000' }
    given!(:imprintable) { create :valid_imprintable, sku: '0705' }

    scenario 'user is informed that the size could not be found' do
      visit fba_orders_path
      click_link 'New FBA Order'

      fill_in 'Name', with: 'Test FBA'
      fill_in 'Deadline', with: 'Feb 04, 2015, 12:00 PM'

      click_button 'Next'
      sleep 0.2

      attach_file 'packing_slips_', packing_slip_path
      wait_for_ajax
      expect(page).to have_content %(Unable to locate size with sku '02')
    end
  end
end
