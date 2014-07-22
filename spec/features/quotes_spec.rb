require 'spec_helper'
include ApplicationHelper

feature 'Quotes management', quote_spec: true, js: true do
  given!(:valid_user) { create(:alternate_user) }
  before(:each) do
    login_as(valid_user)
  end

  given!(:quote) { create(:valid_quote) }

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
end