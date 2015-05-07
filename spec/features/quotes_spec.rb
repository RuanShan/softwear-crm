require 'spec_helper'
include ApplicationHelper
require 'email_spec'

feature 'Quotes management', quote_spec: true, js: true do
  given!(:valid_user) { create(:alternate_user) }
  background(:each) { login_as(valid_user) }

  given!(:quote) { create(:valid_quote) }
  given!(:imprintable) { create(:valid_imprintable) }

  given(:good_variant) { create(:valid_imprintable_variant) }
  given(:better_variant) { create(:valid_imprintable_variant) }
  given(:best_variant) { create(:valid_imprintable_variant) }

  given(:good_imprintable) { good_variant.imprintable }
  given(:better_imprintable) { better_variant.imprintable }
  given(:best_imprintable) { best_variant.imprintable }

  given(:imprintable_group) do
    ImprintableGroup.create(name: 'test group', description: 'yes').tap do |group|
      iig1 = ImprintableImprintableGroup.new
      iig1.tier = Imprintable::TIER.good
      iig1.default = true
      iig1.imprintable = good_imprintable
      iig1.imprintable_group = group
      iig1.save!

      iig2 = ImprintableImprintableGroup.new
      iig2.tier = Imprintable::TIER.better
      iig2.default = true
      iig2.imprintable = better_imprintable
      iig2.imprintable_group = group
      iig2.save!

      iig3 = ImprintableImprintableGroup.new
      iig3.tier = Imprintable::TIER.best
      iig3.default = true
      iig3.imprintable = best_imprintable
      iig3.imprintable_group = group
      iig3.save!
    end
  end

  scenario 'A user can see a list of quotes' do
    visit root_path
    unhide_dashboard
    click_link 'quotes_list'
    click_link 'quotes_path_link'
    expect(page).to have_selector('.box-info')
    expect(current_path).to eq(quotes_path)
  end

  scenario 'A user can create a quote' do
    visit root_path
    unhide_dashboard

    click_link 'quotes_list'
    click_link 'new_quote_link'
    expect(current_path).to eq(new_quote_path)

    fill_in 'Email', with: 'test@spec.com'
    fill_in 'First Name', with: 'Capy'
    fill_in 'Last Name', with: 'Bara'
    click_button 'Next'
    sleep 0.5

    fill_in 'Quote Name', with: 'Quote Name'
    find('#quote_quote_source').find("option[value='Other']").click
    sleep 1
    fill_in 'Valid Until Date', with: Time.now + 1.day
    fill_in 'Estimated Delivery Date', with: Time.now + 1.day
    click_button 'Next'
    sleep 0.5

    fill_in 'line_item_group_name', with: 'Sweet as hell line items'
    click_link 'Add Line Item'
    fill_in 'Name', with: 'Line Item Name'
    fill_in 'Description', with: 'Line Item Description'
    fill_in 'Qty.', with: 2
    fill_in 'Unit Price', with: 15
    click_button 'Submit'

    wait_for_ajax
    expect(page).to have_selector '.modal-content-success', text: 'Quote was successfully created.'
    expect(current_path). to eq(quote_path(quote.id + 1))
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

  scenario 'A user can add an imprintable group of line items to a quote', story_567: true do
    imprintable_group
    visit edit_quote_path quote

    find('a', text: 'Line Items').click

    click_link 'Add A New Group'

    select imprintable_group.name, from: 'Imprintable group'
    fill_in 'Quantity', with: 10
    fill_in 'Decoration price', with: 12.55

    click_button 'Add Group'

    expect(page).to have_content 'Quote was successfully updated.'
    quote.reload

    expect(quote.jobs.size).to be > 0
    expect(quote.jobs.where(name: imprintable_group.name)).to exist
    job = quote.jobs.where(name: imprintable_group.name).first
    expect(job.line_items.where(imprintable_variant_id: good_variant)).to exist
    expect(job.line_items.where(imprintable_variant_id: better_variant)).to exist
    expect(job.line_items.where(imprintable_variant_id: best_variant)).to exist
  end

  feature 'Quote emailing' do
    scenario 'A user can email a quote to the customer' do
      visit edit_quote_path quote.id
      find('a[href="#quote_actions"]').click
      click_link 'Email Quote'
      sleep 0.5
      find('input[value="Submit"]').click
      sleep 0.5

      expect(page).to have_selector '.modal-content-success'
      expect(current_path).to eq(edit_quote_path quote.id)
    end

    scenario 'CC\'s current salesperson by default' do
      visit edit_quote_path quote.id
      find('a[href="#quote_actions"]').click
      click_link 'Email Quote'
      sleep 0.5
      expect(page).to have_selector "input#cc[value='#{valid_user.full_name} <#{ valid_user.email }>']"
    end

    feature 'email recipients enforces proper formatting' do
      scenario 'no email is sent with improper formatting', pending: 'The pattern to validate this field is correct,
                                                                      but for some reason isn\'t tripping when it should' do
        visit edit_quote_path quote.id
        find('a[href="#actions"]').click
        click_link 'Email Quote'
        sleep 0.5
        fill_in 'email_recipients', with: 'this.is.not@formatted.properly.com'
        find('input[value="Submit"]').click
        sleep 0.5

        expect(page).to_not have_selector '.modal-content-success'
        expect(page).to have_content 'Send Quote'
      end
    end
  end

  scenario 'A user can generate a quote from an imprintable pricing dialog', retry: 2, story_489: true do
    visit imprintables_path
    find('i.fa.fa-dollar').click
    decoration_price = 3.75
    sleep 0.5
    fill_in 'Decoration Price', with: decoration_price
    fill_in 'Quantity', with: 3
    fill_in 'pricing_group_text', with: 'Line Items'
    sleep 0.5

    click_button 'Add to Pricing Table'

    click_link 'Create Quote from Table'
    fill_in 'Email', with: 'something@somethingelse.com'
    fill_in 'First Name', with: 'Capy'
    fill_in 'Last Name', with: 'Bara'
    click_button 'Next'
    sleep 0.5

    fill_in 'Quote Name', with: 'Quote Name'
    find('#quote_quote_source').find("option[value='Other']").click
    sleep 1
    fill_in 'Valid Until Date', with: Time.now + 1.day
    fill_in 'Estimated Delivery Date', with: Time.now + 1.day
    click_button 'Next'
    sleep 0.5

    expect(page).to have_css("input[name*='name'][value='#{ imprintable.name }']")
    expect(page).to have_css("input[name*='price'][value='#{ imprintable.base_price + decoration_price }']")
    expect(page).to have_css("input[name*='quantity'][value='3']")
    fill_in 'Description', with: 'Description'
    click_button 'Submit'

    expect(page).to have_selector '.modal-content-success', text: 'Quote was successfully created.'
    expect(current_path).to eq(quote_path(quote.id + 1))
  end

  scenario 'A user can add a single price from the pricing table to an existing quote', retry: 2 do
    visit imprintables_path
    find("#pricing_button_#{imprintable.id}").click
    fill_in 'decoration_price', with: '3.95'
    sleep 0.5
    fill_in 'pricing_group_text', with: 'Line Items'
    sleep 0.5

    click_button 'Add to Pricing Table'
    sleep 0.5
    click_link 'Add to Quote'
    sleep 0.5
    page.find('div.chosen-container').click
    sleep 1
    page.find('li.active-result').click
    click_button 'Add To Quote'

    sleep 1
    expect(current_path).to eq(edit_quote_path quote.id)
    find('a[href="#line_items"]').click
    expect(page).to have_content(imprintable.name)
  end

  scenario "Inputting bad data for a line item doesn't remove all line items", story_249: true  do
    visit new_quote_path
    fill_in 'Email', with: 'test@testing.com'
    fill_in 'First Name', with: 'Capy'
    fill_in 'Last Name', with: 'Bara'
    click_button 'Next'
    sleep 0.5

    fill_in 'Quote Name', with: 'Quote Name'
    fill_in 'Valid Until Date', with: Time.now + 1.day
    fill_in 'Estimated Delivery Date', with: Time.now + 1.day
    click_button 'Next'
    sleep 0.5

    click_link 'Add Line Item'
    fill_in 'Name', with: 'This Should Still be here!'
    fill_in 'Description', with: 'Line Item Description'
    fill_in 'Qty.', with: 2
    fill_in 'Unit Price', with: 15

    click_link 'Add Line Item'
    click_button 'Submit'
    close_error_modal
    click_button 'Next'

    expect(page).to have_selector('div.line-item-form', count: 2)
    expect(page).to have_selector("div.line-item-form input[value='This Should Still be here!']")
    expect(page).to have_selector('div.line-item-form textarea', text: 'Line Item Description')
  end

  scenario 'Pricing table prices with > 2 decimal places are rounded', story_491: true do
    imprintable = build_stubbed :valid_imprintable
    session = {
      pricing_groups: {
        :'GROUP' => [imprintable.pricing_hash(4)]
      }
    }
    session[:pricing_groups][:'GROUP'][0][:prices][:base_price] = 0.54322112312312
    page.set_rack_session(session)

    visit new_quote_path
    click_button 'Next'
    sleep 0.5
    click_button 'Next'

    expect(page).to have_selector("input[type='text'][value='0.54']")
  end

  scenario 'Inputting bad data for the quote does not kill line item info', story_491: true do
    imprintable = build_stubbed :valid_imprintable
    session = {
      pricing_groups: {
        :'GROUP' => [imprintable.pricing_hash(4)]
      }
    }
    page.set_rack_session(session)

    visit new_quote_path
    # fill_in 'Email', with: 'test@testing.com'
    fill_in 'First Name', with: 'Capy'
    fill_in 'Last Name', with: 'Bara'
    click_button 'Next'
    sleep 0.5

    fill_in 'Quote Name', with: 'Quote Name'
    fill_in 'Valid Until Date', with: Time.now + 1.day
    fill_in 'Estimated Delivery Date', with: Time.now + 1.day
    click_button 'Next'
    sleep 0.5

    fill_in 'Qty.', with: 2

    click_button 'Submit'
    sleep 0.5
    find('button[data-dismiss="modal"]').click

    click_button 'Next'
    sleep 1
    click_button 'Next'

    expect(page).to have_selector("input[id$='_quantity'][value='2']")
  end

  scenario 'Error reports turn the page to the first on on which there is an error', story_491: true do
    visit new_quote_path
    fill_in 'Email', with: 'test@testing.com'
    fill_in 'First Name', with: 'Capy'
    fill_in 'Last Name', with: 'Bara'
    fill_in 'Company', with: 'stuff'
    click_button 'Next'
    sleep 0.5

    click_button 'Next'
    sleep 0.5
    click_button 'Submit'

    sleep 0.5
    find('button[data-dismiss="modal"]').click

    expect(page).to have_selector(".current[data-step='2']")
  end

  feature 'search', search_spec: true, solr: true do
    given!(:quote1) { create(:quote, name: 'The keyword') }
    given!(:quote2) { create(:quote, name: 'Something else') }
    given!(:quote3) { create(:quote, name: 'Keyword one again') }

    scenario 'user can search quotes', story_305: true do
      visit quotes_path

      fill_in 'search_quote_fulltext', with: 'Keyword'
      click_button 'Search'
      expect(page).to have_content 'The keyword'
      expect(page).to have_content 'Keyword one again'
      expect(page).to have_content 'Something else'
    end

  end

  feature 'the following actions are tracked:' do
    scenario 'Quote creation' do
      visit root_path
      unhide_dashboard
      click_link 'quotes_list'
      click_link 'new_quote_link'
      expect(current_path).to eq(new_quote_path)

      fill_in 'Email', with: 'test@spec.com'
      fill_in 'First Name', with: 'Capy'
      fill_in 'Last Name', with: 'Bara'
      click_button 'Next'
      sleep 0.5

      fill_in 'Quote Name', with: 'Quote Name'
      fill_in 'Valid Until Date', with: Time.now + 1.day
      fill_in 'Estimated Delivery Date', with: Time.now + 1.day
      click_button 'Next'
      sleep 0.5

      click_link 'Add Line Item'
      sleep 0.5

      fill_in 'Name', with: 'Line Item Name'
      fill_in 'Description', with: 'Line Item Description'
      fill_in 'Qty.', with: 2
      fill_in 'Unit Price', with: 15
      click_button 'Submit'

      activity = quote.all_activities.to_a.select{ |a| a[:key] = 'quote.create' }
      expect(activity).to_not be_nil
    end

    scenario 'A quote being emailed to the customer' do
      visit edit_quote_path quote.id
      click_link 'Actions'
      click_link 'Email Quote'
      sleep 1

      click_button 'Submit'
      expect(current_path).to eq(edit_quote_path quote.id)
      expect(page).to have_selector '.modal-content-success', text: 'Your email was successfully sent!'

      activities_array = quote.all_activities.to_a
      activity = activities_array.select { |a| a[:key] = 'quote.emailed_customer' }
      expect(activity).to_not be_nil
    end

    scenario 'A quote being edited' do
      visit edit_quote_path quote.id
      click_link 'Details'
      fill_in 'Quote Name', with: 'Edited Quote Name'
      click_button 'Save'

      expect(current_path).to eq(quote_path quote.id)
      expect(page).to have_selector '.modal-content-success', text: 'Quote was successfully updated.'
      activity = quote.all_activities.to_a.select{ |a| a[:key] = 'quote.update' }
      expect(activity).to_not be_nil
    end

    scenario 'A line item changing' do
      visit edit_quote_path quote.id
      click_link 'Line Items'
      line_item_id = quote.line_items.first.id
      find("#line-item-#{line_item_id} .line-item-button[title='Edit']").click
      wait_for_ajax

      find("#line_item_#{line_item_id}_taxable").click
      find('.btn.update-line-items').click
      wait_for_ajax

      activity = quote.all_activities.to_a.select{ |a| a[:key] = 'quote.updated_line_item' }
      expect(activity).to_not be_nil
    end
  end
end
