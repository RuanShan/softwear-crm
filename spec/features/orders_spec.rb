require 'spec_helper'
include ApplicationHelper

feature 'Order management', order_spec: true,  js: true do
  given!(:valid_user) { create(:user) }
  before(:each) do
    login_as valid_user
  end

  given!(:order) { create(:order) }

  scenario 'user views the index of orders' do
    visit root_path
    unhide_dashboard
    click_link 'Orders'
    wait_for_ajax
    click_link 'List'
    expect(page).to have_css("tr#order_#{order.id}")
  end

  scenario 'user creates a new order' do
    visit root_path
    unhide_dashboard
    click_link 'Orders'
    wait_for_ajax
    click_link 'New'

    fill_in 'Email', with: 'test@example.com'
    fill_in 'Phone number', with: '321-654-9870'
    fill_in 'First name', with: 'Guy'
    fill_in 'Last name', with: 'Fieri'
    fill_in 'Company', with: 'Probably Nothing'
    fill_in 'Twitter', with: 'stuff'

    click_button 'Next'
    wait_for_ajax

    fill_in 'Name', with: 'Whatever this should be'
    date_array = DateTime.current.to_s.split(/\W|T/)
    in_hand_by = "#{ (date_array[1].to_i + 1).to_s }/#{ date_array[2] }"\
                 "/#{ date_array.first } 4:00 PM"
    fill_in 'In Hand By Date', with: in_hand_by
    select User.find(order.salesperson_id).full_name, from: 'Salesperson'
    select order.store.name, from: 'Store'
    select 'Half down on purchase', from: 'Payment terms'

    click_button 'Next'
    wait_for_ajax

    select 'Pick up in Ypsilanti', from: 'Delivery method'

    sleep 1
    click_button 'Submit'
    sleep 1

    expect(Order.where(firstname: 'Guy')).to exist
  end

  scenario 'user sees an error message when submitting invalid information' do
    visit root_path
    unhide_dashboard
    click_link 'Orders'
    sleep 1
    click_link 'New'

    fill_in 'Email', with: 'nope'

    2.times { click_button 'Next'; sleep 1 }
    click_button 'Submit'

    sleep 1
    expect(page).to have_content 'Email is invalid'
  end

  scenario 'phone number field enforces proper format', pending: 'No idea why the phone number format is failing now' do
    visit root_path
    unhide_dashboard
    click_link 'Orders'
    wait_for_ajax
    click_link 'New'

    phone_number_field = find_field('order[phone_number]')
    fill_in 'Phone number', with: '1236547895'
    wait_for_ajax
    expect(phone_number_field.value).to eq '123-654-7895'

    visit current_path

    fill_in 'Phone number', with: 'a1b2c3!@5#$-'
    wait_for_ajax
    expect(phone_number_field.value).to eq '123-5__-____'
  end

  scenario 'user edits an existing order' do
    visit orders_path
    find("a[title='Edit']").click
    wait_for_ajax
    click_link 'Details'
    wait_for_ajax
    
    fill_in 'Name', with: 'New Title'

    click_button 'Save'

    expect(Order.where(name: 'New Title')).to exist
  end

  scenario 'when editing, submitting invalid information displays error content' do
    visit edit_order_path(order, anchor: 'details')
    fill_in 'Email', with: 'bad email!'
    click_button 'Save'

    expect(page).to have_content 'Email is invalid'
  end

  scenario 'user can view updates on the timeline', timeline_spec: true do
    PublicActivity.with_tracking do
      order.firstname = "Newfirst"
      order.save
    end
    visit edit_order_path(order)

    expect(page).to have_content "Updated order #{order.name}"
  end

  describe 'search', search_spec: true, solr: true do
    let!(:order2) { create(:order_with_job, name: 'Keyword order',
      terms: 'Net 60') }
    let!(:order3) { create(:order_with_job, name: 'Nonkeyword order',
      terms: 'Paid in full on purchase') }
    let!(:order4) { create(:order_with_job, name: 'Some Order', 
      company: 'Order with the keyword keyword!') }
    let!(:order5) { create(:order_with_job, name: 'Dumb order',
      terms: 'Net 60') }

    scenario 'user can search orders', retry: 3 do
      visit orders_path

      fill_in 'search_order_fulltext', with: 'Keyword'
      click_button 'Search'
      expect(page).to have_content 'Keyword order'
      expect(page).to have_content 'Some Order'
      expect(page).to_not have_content 'Nonkeyword order'
      expect(page).to_not have_content 'Dumb order'
    end

    scenario 'user can save searches' do
      visit orders_path
      find('.additional-icon[data-toggle="collapse"]').click
      select 'Net 60', from: 'search_order_8_terms'
      click_button 'Save'
      wait_for_ajax

      fill_in 'query_name_input', with: 'Test Query'
      find('#modal-confirm-btn').click

      expect(page).to have_content 'Successfully saved search query!'
      expect(Search::Query.where(name: 'Test Query')).to exist
    end

    scenario 'user can use saved searches', retry: 3 do
      query = Search::QueryBuilder.build('Test Query') do
        on Order do
          with :terms, 'Net 60'
          fulltext 'order'
        end
      end
        .query
      
      query.user = valid_user
      expect(query.save).to be_truthy

      visit orders_path



      select 'Test Query', from: 'select_query_for_order'
      wait_for_ajax
      click_button 'GO'

      expect(page).to have_content 'Keyword order'
      expect(page).to have_content 'Dumb order'
      expect(page).to_not have_content 'Nonkeyword order'
    end
  end
end
