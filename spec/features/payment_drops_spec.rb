require 'spec_helper'
include ApplicationHelper

feature 'Payment Drops management', payment_drop_spec: true do
  given!(:valid_user) { create(:user) }
  given!(:store) { create(:valid_store) }

  background(:each) { login_as(valid_user) }

  scenario 'Sales Manager can access list of payment drops'
  scenario 'Sales Manager can create a payment drop'
  scenario "Sales manager must enter a reason when cash doesn't match expected cash"


end
