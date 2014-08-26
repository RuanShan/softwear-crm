require 'spec_helper'
include ApplicationHelper

feature 'Pricing management', js: true, prices_spec: true do
  given!(:valid_user) { create(:alternate_user) }
  background(:each) { login_as(valid_user) }

  given!(:imprintable) { create(:valid_imprintable) }

  scenario 'A user can price an imprintable' do
    visit imprintables_path
    click_link("pricing_button_#{imprintable.id}")
    fill_in 'decoration_price', with: '5'
    click_button 'Fetch Prices!'

    expect(page).to have_css('td', text: "#{imprintable.base_price + 5}")
    expect(page).to have_css('td', text: "#{imprintable.xxl_price + 5}")
    expect(page).to have_css('td', text: "#{imprintable.xxxl_price + 5}")
    expect(page).to have_css('td', text: "#{imprintable.xxxxl_price + 5}")
    expect(page).to have_css('td', text: "#{imprintable.xxxxxl_price + 5}")
    expect(page).to have_css('td', text: "#{imprintable.xxxxxxl_price + 5}")

    expect(page).to have_content 'Base Price'
    expect(page).to have_content '2XL'
    expect(page).to have_content '3XL'
    expect(page).to have_content '4XL'
    expect(page).to have_content '5XL'
    expect(page).to have_content '6XL'
  end

  scenario 'A user can delete a single price from the pricing table' do
    visit imprintables_path
    click_link("pricing_button_#{imprintable.id}")
    fill_in 'decoration_price', with: '5'
    click_button 'Fetch Prices!'

    expect(page).to have_css('tr#price_0')

    find(:css, '#price_actions_0 a[data-action="destroy"]').click
    page.driver.browser.switch_to.alert.accept

    expect(page).to_not have_css('tr#price_0')
  end

  context 'There are two different prices in the pricing table', slow: true do
    background(:each) do
      session = [
        {
          name: imprintable.name,
          supplier_link: imprintable.supplier_link,
          sizes: 'S - L',
          prices: {
              base_price: 10,
              xxl_price: 12,
              xxxl_price: 14,
              xxxxl_price: 15,
              xxxxxl_price: 16,
              xxxxxxl_price: 17
          }
        },
        {
          name: imprintable.name,
          supplier_link: imprintable.supplier_link,
          sizes: 'M - XL',
          prices: {
              base_price: 5,
              xxl_price: 6,
              xxxl_price: 7,
              xxxxl_price: 8,
              xxxxxl_price: 9,
              xxxxxxl_price: 10
          }
        }
      ]
      page.set_rack_session(prices: session)
    end

    scenario 'A user can delete all prices from the pricing table' do
      visit imprintables_path
      click_link 'View Pricing Table'

      expect(page).to have_css('tr#price_0')
      expect(page).to have_css('tr#price_1')

      sleep 0.5
      find(:css, 'a[data-action="destroy_all"]').click
      page.driver.browser.switch_to.alert.accept

      expect(page).to_not have_css('tr#price_0')
      expect(page).to_not have_css('tr#price_1')
    end
  end
end
