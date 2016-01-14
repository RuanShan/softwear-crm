require 'spec_helper'

feature 'FBA Order management', fba_spec: true, story_103: true, js: true, retry: 3 do
  given!(:valid_user) { create :user }
  background(:each) { login_as valid_user }

  given(:packing_slip_path) { "#{Rails.root}/spec/fixtures/fba/TestPackingSlip.txt" }
  given(:multi_packing_slip_path) { "#{Rails.root}/spec/fixtures/fba/PackingSlipMulti.txt" }

  # Dashboard doesn't even work on ci
  unless ci?
    scenario 'user can view an index of FBA orders from the sidebar' do
      visit root_path
      unhide_dashboard
      click_link 'FBA Orders'
      click_link 'List FBA Orders'
    end
  end

  context 'given multiple valid imprintables', story_957: true do
    before(:each) do
      Capybara.ignore_hidden_elements = false
    end

    after(:each) do
      Capybara.ignore_hidden_elements = true
    end

    given!(:size_xs) { create :valid_size, sku: '01' }
    given!(:size_s) { create :valid_size, sku: '02' }
    given!(:size_m) { create :valid_size, sku: '03' }
    given!(:size_l) { create :valid_size, sku: '04' }
    given!(:size_xl) { create :valid_size, sku: '05' }
    given!(:size_2xl) { create :valid_size, sku: '06' }
    given!(:size_3xl) { create :valid_size, sku: '07' }
    given!(:color) { create :valid_color, sku: '003' }
    given!(:imprintable_1) { create :valid_imprintable, sku: '0100' }
    given!(:imprintable_2) { create :valid_imprintable, sku: '1000' }

    background do
      [size_xs, size_s, size_m, size_l, size_xl, size_2xl, size_3xl].each do |size|
        ImprintableVariant.create!(
          imprintable_id: imprintable_1.id,
          size_id:  size.id,
          color_id: color.id
        )
        unless size == size_xs || size == size_3xl
          ImprintableVariant.create!(
            imprintable_id: imprintable_2.id,
            size_id:  size.id,
            color_id: color.id
          )
        end
      end
    end

    scenario 'user can create a new FBA order', retry: 3 do
      visit fba_orders_path
      click_link 'New FBA Order'

      fill_in 'Name', with: 'Test FBA'
      fill_in 'Deadline', with: 'Feb 04, 2015, 12:00 PM'

      click_button 'Next'
      sleep 0.2

      find('#js-upload-packing-slips-button').click
      wait_for_ajax
      attach_file 'packing_slips_', multi_packing_slip_path
      click_button 'Upload'

      sleep 1

      expect(page).to have_content 'Job and line items will be generated'

      click_button 'Next'
      sleep 0.5
      all('input[value="Submit"]').first.click

      sleep 2
      expect(Order.fba.where(name: 'Test FBA')).to exist
      order = Order.fba.find_by(name: 'Test FBA')
      expect(order.jobs.count).to eq 1
      expect(order.jobs.first.line_items.count).to eq 12
      expect(order.jobs.first.line_items.first.quantity).to eq 1

      expect(page).to have_content 'Test FBA'
    end

    context 'when one imprintable has "toddler" (or "onesie" or "infant") in the name' do
      background do
        imprintable_1.update_column :style_name, 'Some Kind of Onesie'
      end

      it 'creates a separate job for the toddler/infant/onesie imprintable', no_ci: true, pending: 'Nigel todo' do
        visit fba_orders_path
        click_link 'New FBA Order'

        fill_in 'Name', with: 'Test FBA'
        fill_in 'Deadline', with: 'Feb 04, 2015, 12:00 PM'

        click_button 'Next'
        sleep 0.2

        find('#js-upload-packing-slips-button').click
        wait_for_ajax
        attach_file 'packing_slips_', multi_packing_slip_path
        click_button 'Upload'

        sleep 1

        expect(page).to have_content 'Job and line items will be generated'

        click_button 'Next'
        sleep 0.5
        all('input[value="Submit"]').first.click

        sleep 2
        expect(Order.fba.where(name: 'Test FBA')).to exist
        order = Order.fba.find_by(name: 'Test FBA')
        expect(order.jobs.count).to eq 2
        expect(order.line_items.count).to eq 12
        expect(order.line_items.first.quantity).to eq 1

        expect(page).to have_content 'Test FBA'
      end
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
        click_button 'Upload'

        sleep 1

        expect(page).to have_content 'Job and line items will be generated'

        click_button 'Next'
        sleep 0.5
        all('input[value="Submit"]').first.click

        sleep 2
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

        scenario 'user is informed', color: true, retry: 3 do
          visit fba_orders_path
          click_link 'New FBA Order'

          fill_in 'Name', with: 'Test FBA'
          fill_in 'Deadline', with: 'Feb 04, 2015, 12:00 PM'

          click_button 'Next'

          find('#js-upload-packing-slips-button').click
          wait_for_ajax
          attach_file 'packing_slips_', packing_slip_path
          click_button 'Upload'
          wait_for_ajax
          sleep 0.2

          expect(page).to have_content %(No color with SKU 000 was found)
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

    background do
      [other_size_s, size_m, size_l, size_xl].each do |size|
        ImprintableVariant.create!(
          imprintable_id: imprintable.id,
          size_id:  size.id,
          color_id: color.id
        )
      end
    end

    scenario 'user is informed that the size could not be found', retry: 3 do
      visit fba_orders_path
      click_link 'New FBA Order'

      fill_in 'Name', with: 'Test FBA'
      fill_in 'Deadline', with: 'Feb 04, 2015, 12:00 PM'

      click_button 'Next'
      sleep 0.2

      find('#js-upload-packing-slips-button').click
      wait_for_ajax
      attach_file 'packing_slips_', packing_slip_path
      click_button 'Upload'
      wait_for_ajax

      expect(page).to have_content %(No size with SKU 02 was found)
    end
  end
end
