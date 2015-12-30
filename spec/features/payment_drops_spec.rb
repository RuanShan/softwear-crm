require 'spec_helper'
include ApplicationHelper

feature 'Payment Drops management', payment_drop_spec: true do
  given!(:valid_user) { create(:user) }
  given!(:store) { create(:valid_store) }

  background(:each) { login_as(valid_user) }

  scenario 'Sales Manager can access list of payment drops' do
    visit root_path
    click_link 'Payment Drops'
    expect(page).to have_css("tr##{model_table_row_id(store)}")
  end

  scenario 'Sales Manager can create a payment drop' do
    visit root_path
    click_link 'Payment Drops'
    expect(page).to have_css("tr##{model_table_row_id(store)}")
  end


end
