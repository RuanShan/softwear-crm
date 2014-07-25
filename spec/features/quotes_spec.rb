require 'spec_helper'
include ApplicationHelper
require 'email_spec'

feature 'Quotes management', quote_spec: true, js: true do
  given!(:valid_user) { create(:alternate_user) }
  before(:each) do
    login_as(valid_user)
  end

  given!(:quote) { create(:valid_quote) }
  given!(:imprintable) { create(:valid_imprintable) }

  scenario 'A user can see a list of quotes' do
    visit root_path
    unhide_dashboard
    click_link 'quotes_list'
    click_link 'quotes_path_link'
    expect(page).to have_selector('.box-info')
    expect(current_path).to eq(quotes_path)
  end

  scenario 'A user can visit the edit quote page' do
    visit quotes_path
    find('i.fa.fa-edit').click
    expect(current_path).to eq(edit_quote_path quote.id)
  end

  scenario 'A user can edit a quote' do
    visit edit_quote_path quote.id
    find('a', text: 'Details').click
    fill_in 'Quote Name', with: 'New Quote Name'
    click_button 'Save'
    expect(current_path).to eq(quote_path quote.id)
    expect(quote.reload.name).to eq('New Quote Name')
  end

  scenario 'A user can email a quote to the customer' do
    visit edit_quote_path quote.id
    find('a[href="#actions"]').click
    click_button 'Email Quote'
    wait_for_ajax
    find('input[value="Submit"]').click
    expect(current_path).to eq(edit_quote_path quote.id)
  end

  scenario 'A user can generate a quote from an imprintable pricing dialog' do
    visit imprintables_path
    decoration_price = 3.75
    find('i.fa.fa-dollar').click
    fill_in 'Decoration Price', with: decoration_price
    click_button 'Fetch Prices!'
    click_link 'Create Quote from Table'
    fill_in 'Email', with: 'something@somethingelse.com'
    fill_in 'First Name', with: 'Capy'
    fill_in 'Last Name', with: 'Bara'
    click_button 'Next'
    fill_in 'Valid Until Date', with: Time.now + 1.day
    fill_in 'Estimated Delivery Date', with: Time.now + 1.day
    click_button 'Next'
    expect(page).to have_css("input[value='#{ imprintable.name }']")
    expect(page).to have_css("input[value='#{ imprintable.base_price + decoration_price }']")
    fill_in 'Description', with: 'Gaga can\'t handle this shit'
    fill_in 'Quantity', with: '1'
    click_button 'Submit'
    expect(page).to have_selector '.modal-content-success', text: 'Quote was successfully created.'
    expect(current_path).to eq(quote_path(quote.id + 1))
  end

  scenario 'A user can add a single price from the pricing table to an existing quote' do
    visit imprintables_path
    find("#pricing_button_#{imprintable.id}").click
    fill_in 'Decoration Price', with: 3.95
    click_button 'Fetch Prices!'
    click_link 'Add to Quote'
    page.select quote.name, from: 'quote_id'
    click_button 'Submit'
    expect(current_path).to eq(edit_quote_path quote.id)
    find('a[href="#line_items"]').click
    expect(page).to have_content(imprintable.name)
  end
end
