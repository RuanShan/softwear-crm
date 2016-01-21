require 'spec_helper'
include LineItemHelpers

feature 'FBA Order management', fba_spec: true, story_103: true, js: true, retry: ci? ? 3 : 0 do
  given!(:valid_user) { create :user }
  background(:each) { login_as valid_user }

  given!(:fba_shipping_method) { ShippingMethod.find_by(name: ShippingMethod::FBA) || create(:valid_shipping_method, name: ShippingMethod::FBA) }

  given(:packing_slip_path) { "#{Rails.root}/spec/fixtures/fba/TestPackingSlip.txt" }
  given(:multi_packing_slip_path) { "#{Rails.root}/spec/fixtures/fba/PackingSlipMulti.txt" }
  given(:bad_sku_packing_slip_path) { "#{Rails.root}/spec/fixtures/fba/PackingSlipBadSku.txt" }

  before(:each) do
    Capybara.ignore_hidden_elements = false
  end

  after(:each) do
    Capybara.ignore_hidden_elements = true
  end


  # Dashboard doesn't even work on ci
  unless ci?
    scenario 'user can view an index of FBA orders from the sidebar' do
      visit root_path
      unhide_dashboard
      click_link 'FBA Orders'
      click_link 'List FBA Orders'
    end
  end

  given!(:shirt) { create(:associated_imprintable) }
  given!(:sweater) { create(:associated_imprintable) }

  given!(:red) { create(:valid_color, name: 'RRed') }

  make_variants :red, :shirt,   [:XS, :S, :M, :L, :XL, :XXL, :XXXL], not: %i(line_item job)
  make_variants :red, :sweater, [:XS, :S, :M, :L, :XL, :XXL, :XXXL], not: %i(line_item job)

  given!(:job_template) { create(:fba_job_template_with_imprint, name: 'Test Template') }

  given(:scuba_doitdeeper_shirt) do
    create(
      :fba_product,
      name: 'Scooba Shirt', sku: 'scuba_doitdeeper',
      fba_skus_attributes: {
        0 => {
          sku: '0-scuba_doitdeeper-2010001003',
          imprintable_variant_id: red_shirt_xs.id,
          fba_job_template_id: job_template.id
        },
        1 => {
          sku: '0-scuba_doitdeeper-2010002003',
          imprintable_variant_id: red_shirt_s.id,
          fba_job_template_id: job_template.id
        },
        2 => {
          sku: '0-scuba_doitdeeper-2010003003',
          imprintable_variant_id: red_shirt_m.id,
          fba_job_template_id: job_template.id
        },
        3 => {
          sku: '0-scuba_doitdeeper-2010004003',
          imprintable_variant_id: red_shirt_l.id,
          fba_job_template_id: job_template.id
        },
        4 => {
          sku: '0-scuba_doitdeeper-2010005003',
          imprintable_variant_id: red_shirt_xl.id,
          fba_job_template_id: job_template.id
        },
        5 => {
          sku: '0-scuba_doitdeeper-2010006003',
          imprintable_variant_id: red_shirt_xxl.id,
          fba_job_template_id: job_template.id
        },
        6 => {
          sku: '0-scuba_doitdeeper-2010007003',
          imprintable_variant_id: red_shirt_xxxl.id,
          fba_job_template_id: job_template.id
        }
      }
    )
  end

  given(:scuba_doitdeeper_sweater) do
    create(
      :fba_product,
      name: 'Scooba Sweater', sku: 'scuba_doitdeeper',
      fba_skus_attributes: {
        0 => {
          sku: '0-scuba_doitdeeper-2100002003',
          imprintable_variant_id: red_sweater_s.id,
          fba_job_template_id: job_template.id
        },
        1 => {
          sku: '0-scuba_doitdeeper-2100003003',
          imprintable_variant_id: red_sweater_m.id,
          fba_job_template_id: job_template.id
        },
        2 => {
          sku: '0-scuba_doitdeeper-2100004003',
          imprintable_variant_id: red_sweater_l.id,
          fba_job_template_id: job_template.id
        },
        3 => {
          sku: '0-scuba_doitdeeper-2100005003',
          imprintable_variant_id: red_sweater_xl.id,
          fba_job_template_id: job_template.id
        },
        4 => {
          sku: '0-scuba_doitdeeper-2100006003',
          imprintable_variant_id: red_sweater_xxl.id,
          fba_job_template_id: job_template.id
        }
      }
    )
  end

  context 'when matching FBA Products are present,', valid_data: true do
    background { scuba_doitdeeper_shirt; scuba_doitdeeper_sweater }

    scenario 'a user can create an FBA order with the jobs, line items, and shipments specified by a packing slip', create: true do
      visit new_fba_orders_path
      fill_in 'Name', with: 'An FBA Order'
      fill_in 'Deadline', with: '12/25/2025 12:00 AM'

      click_button 'Next'
      sleep 1
      click_link 'Upload Packing Slip(s)'
      sleep 1
      drop_in_dropzone multi_packing_slip_path
      sleep ci? ? 3 : 1
      click_button "close-packing-slip-modal"
      wait_for_ajax

      expect(page).to have_content 'PackingSlipMulti.txt'
      expect(page).to have_content 'Jobs and line items will be added'

      click_button 'Next'
      sleep ci? ? 3 : 1
      find('.big-submit-button').click
      sleep ci? ? 3 : 1

      order = Order.fba.where(name: 'An FBA Order')
      expect(order).to exist
      expect(page).to have_content 'An FBA Order'
      order = order.first
      expect(
        order.jobs.joins(:imprints).where(imprints: { print_location_id: job_template.imprints.first.id }).size
      ).to eq 2

      expect(order.jobs.where(name: 'Scooba Sweater Test Template - FBA312LM3T')).to exist
      expect(order.jobs.where(name: 'Scooba Shirt Test Template - FBA312LM3T')).to exist

      expect(order.line_items.where(imprintable_object_id: red_shirt_xs.id, quantity: 1)).to exist
      expect(order.line_items.where(imprintable_object_id: red_shirt_s.id, quantity: 1)).to exist
      expect(order.line_items.where(imprintable_object_id: red_shirt_m.id, quantity: 1)).to exist
      expect(order.line_items.where(imprintable_object_id: red_shirt_l.id, quantity: 1)).to exist
      expect(order.line_items.where(imprintable_object_id: red_shirt_xl.id, quantity: 1)).to exist
      expect(order.line_items.where(imprintable_object_id: red_shirt_xxl.id, quantity: 1)).to exist
      expect(order.line_items.where(imprintable_object_id: red_shirt_xxxl.id, quantity: 1)).to exist
      expect(order.line_items.where(imprintable_object_id: red_sweater_s.id, quantity: 1)).to exist
      expect(order.line_items.where(imprintable_object_id: red_sweater_m.id, quantity: 1)).to exist
      expect(order.line_items.where(imprintable_object_id: red_sweater_l.id, quantity: 1)).to exist
      expect(order.line_items.where(imprintable_object_id: red_sweater_xl.id, quantity: 1)).to exist
      expect(order.line_items.where(imprintable_object_id: red_sweater_xxl.id, quantity: 1)).to exist

      expect(order.jobs.first.shipments.where(address_1: '650 Boulder Drive', city: 'Breiningsville', state: 'PA', zipcode: '18031', shipped_by_id: valid_user.id)).to exist
      expect(order.jobs.last.shipments.where(address_1: '650 Boulder Drive', city: 'Breiningsville', state: 'PA', zipcode: '18031', shipped_by_id: valid_user.id)).to exist
    end
  end

  context "when there are some bad skus" do
    scenario 'the user is informed and linked to the fba products page (target=_blank)' do
      visit new_fba_orders_path
      fill_in 'Name', with: 'An FBA Order'
      fill_in 'Deadline', with: '12/25/2025 12:00 AM'

      click_button 'Next'
      click_link 'Upload Packing Slip(s)'
      drop_in_dropzone bad_sku_packing_slip_path
      click_button "close-packing-slip-modal"
      wait_for_ajax

      expect(page).to have_content 'PackingSlipBadSku.txt'
      expect(page).to have_content 'No line items will be added'
      expect(page).to have_selector "a[href='#{fba_products_path}']"
    end
  end
end
