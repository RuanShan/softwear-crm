require 'spec_helper'
include ApplicationHelper

feature 'Pricing management', js: true, prices_spec: true do
  given!(:valid_user) { create(:alternate_user) }
  before(:each) { login_as(valid_user) }

  given!(:imprintable) { create(:valid_imprintable) }

  scenario 'A user can price an imprintable' do
    visit imprintables_path
    click_link("pricing_button_#{ imprintable.id }")
    fill_in 'decoration_price', with: '5'
    find_button('price_submit_button').click
    expect(page).to have_css('td', text: "#{ imprintable.base_price + 5 }")
    expect(page).to have_css('td', text: "#{ imprintable.xxl_price + 5 }")
    expect(page).to have_css('td', text: "#{ imprintable.xxxl_price + 5 }")
    expect(page).to have_css('td', text: "#{ imprintable.xxxxl_price + 5 }")
    expect(page).to have_css('td', text: "#{ imprintable.xxxxxl_price + 5 }")
    expect(page).to have_css('td', text: "#{ imprintable.xxxxxxl_price + 5 }")
    expect(page).to have_content 'Base Price'
    expect(page).to have_content '2XL'
    expect(page).to have_content '3XL'
    expect(page).to have_content '4XL'
    expect(page).to have_content '5XL'
    expect(page).to have_content '6XL'
  end
end
