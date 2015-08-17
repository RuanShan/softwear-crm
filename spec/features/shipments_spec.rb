require 'spec_helper'

feature 'shipment management' do
  given!(:shipping_method) { create(:shipping_method, name: 'USPS First Class') }

  given!(:valid_user) { create(:user) }
  background(:each) { login_as valid_user }

  context 'within an order', js: true, story_860: true do
    given!(:order) { create(:order_with_job) }
    let(:time) { Time.now }

    scenario 'a user can add a shipment' do
      visit edit_order_path(order, anchor: 'shipments')
      sleep 1

      select 'USPS First Class', from: 'Shipping method'
      select valid_user.full_name, from: 'Shipped by'
      fill_in 'Shipping cost',   with: '12.50'
      fill_in 'Shipped at',      with: time.strftime('%m/%d/%Y %I:%M %p')
      fill_in 'Tracking number', with: '1231241321'
      fill_in 'Name',            with: 'Someone'
      fill_in 'Company',         with: 'Ann Arbor Tees'
      fill_in 'Attn',            with: 'wtf?'
      fill_in 'Address 1',       with: '123 whatever st.'
      fill_in 'City',            with: 'Ann Arbor'
      fill_in 'State',           with: 'Michigan'
      fill_in 'Zipcode',         with: '48104'
      fill_in 'Country',         with: 'USA'

      click_button 'Create Shipment'
      sleep 2

      expect(page).to have_content 'Shipment added!'
      first('[data-dismiss=modal]').click
      sleep 1

      expect(order.reload.shipments.size).to eq 1
      shipment = order.shipments.first

      expect(shipment.shipping_method.name).to eq 'USPS First Class'
      expect(shipment.shipped_by).to eq valid_user
      expect(shipment.shipping_cost).to eq 12.50
      expect(shipment.shipped_at.month).to eq time.month
      expect(shipment.shipped_at.day).to eq time.day
      expect(shipment.shipped_at.year).to eq time.year
      expect(shipment.tracking_number).to eq '1231241321'
      expect(shipment.name).to eq 'Someone'
      expect(shipment.company).to eq 'Ann Arbor Tees'
      expect(shipment.attn).to eq 'wtf?'
      expect(shipment.address_1).to eq '123 whatever st.'
      expect(shipment.city).to eq 'Ann Arbor'
      expect(shipment.state).to eq 'Michigan'
      expect(shipment.zipcode).to eq '48104'
      expect(shipment.country).to eq 'USA'
    end
  end
end
