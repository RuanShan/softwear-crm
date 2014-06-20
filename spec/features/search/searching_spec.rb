require 'spec_helper'

feature 'Searching', search_spec: true, js: true do
  given!(:valid_user) { create(:user) }
  before(:each) do
    login_as valid_user
  end

  5.times do |n|
    let!("order_#{n+1}") { create :order_with_job }
  end

  scenario 'a user can search everything' do

  scenario 'a user can perform an advanced search'

  scenario 'a user can save an advanced search'

  scenario 'a user can set a saved advanced search as default'

  scenario 'a user can load an advanced search'
end