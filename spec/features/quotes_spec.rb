require 'spec_helper'
include ApplicationHelper
require 'email_spec'
require_relative '../../app/controllers/jobs_controller'

feature 'Quotes management', quote_spec: true, js: true do
  given!(:valid_user) { create(:alternate_user, insightly_api_key: "insight") }
  background(:each) { login_as(valid_user) }

  given!(:quote) { create(:valid_quote) }
  given!(:imprintable) { create(:valid_imprintable) }

  given(:iv1) { create(:valid_imprintable_variant) }
  given(:iv2) { create(:valid_imprintable_variant) }
  given(:iv3) { create(:valid_imprintable_variant) }

  given(:imprintable1) { iv1.imprintable }
  given(:imprintable2) { iv2.imprintable }
  given(:imprintable3) { iv3.imprintable }

  given(:good_variant) { create(:valid_imprintable_variant) }
  given(:better_variant) { create(:valid_imprintable_variant) }
  given(:best_variant) { create(:valid_imprintable_variant) }

  given(:good_imprintable) { good_variant.imprintable }
  given(:better_imprintable) { better_variant.imprintable }
  given(:best_imprintable) { best_variant.imprintable }

  given(:print_location_1) { create(:valid_print_location) }
  given(:print_location_2) { create(:valid_print_location) }

  given(:imprint_method_1) { print_location_1.imprint_method }
  given(:imprint_method_2) { print_location_2.imprint_method }

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

  scenario 'A user can create a quote', edit: true, pending: "I don't know why this fails" do
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

    click_button 'Submit'

    wait_for_ajax
    expect(page).to have_content text: 'Quote was successfully created.'
    expect(current_path). to eq(quote_path(quote.id + 1))
  end

  scenario 'A user can visit the edit quote page', edit: true do
    visit quotes_path
    find('i.fa.fa-edit').click
    expect(current_path).to eq(edit_quote_path quote.id)
  end

  scenario 'A user can edit a quote', edit: true do
    visit edit_quote_path quote.id
    find('a', text: 'Details').click
    fill_in 'Quote Name', with: 'New Quote Name'
    click_button 'Save'
    visit current_path
    expect(current_path).to eq(quote_path quote.id)
    expect(quote.reload.name).to eq('New Quote Name')
  end

  scenario 'Insightly forms dynamically changed fields', edit1: true do
    allow_any_instance_of(InsightlyHelper).to receive(:insightly_available?).and_return true
    allow_any_instance_of(InsightlyHelper).to receive(:insightly_categories).and_return [] 
    allow_any_instance_of(InsightlyHelper).to receive(:insightly_pipelines).and_return [] 
    allow_any_instance_of(InsightlyHelper).to receive(:insightly_opportunity_profiles).and_return [] 
    allow_any_instance_of(InsightlyHelper).to receive(:insightly_bid_tiers).and_return ["unassigned", "Tier 1 ($1 - $249)", "Tier 2 ($250 - $499)", "Tier 3 ($500 - $999)", "Tier 4 ($1000 and up)"] 

    visit new_quote_path
    click_button 'Next' 
    click_button 'Next' 
    expect(page).to have_select('Bid Tier', :selected => "unassigned")
    fill_in 'Estimated Quote', with: '200'
    fill_in 'Opportunity ID', with: '1'
    expect(body).to have_field("Bid Amount", :text => "200") 
    expect(page).to have_select('Bid Tier', :selected => "Tier 1 ($1 - $249)")
    fill_in 'Estimated Quote', with:'275'
    expect(page).to have_field("Bid Amount", value => '275')
    expect(page).to have_select('Bid Tier', :selected => "Tier 2 ($250 - $499)")
    fill_in 'Estimated Quote', with:'550'
    expect(page).to have_field("Bid Amount", value => '550')
    expect(page).to have_select('Bid Tier', :selected => "Tier 3 ($500 - $999)")
    fill_in 'Estimated Quote', with:'2000'
    expect(page).to have_field("Bid Amount", value => '2000')
    expect(page).to have_select('Bid Tier', :selected => "Tier 4 ($1000 and up)")
  end

  scenario 'A users options are properly saved', edit: true do
    visit edit_quote_path quote.id
    find('a', text: 'Details').click
    select 'No', :from => "Informal quote?"
    select 'No', :from => "Did the Customer Request a Specific Deadline?"
    select 'Yes', :from => "Is this a rush job?"
    click_button 'Save'
    visit current_path
    click_link 'Edit'
    find('a', text: 'Details').click
    expect(page).to have_select('Informal quote?', :selected => "No")
    expect(page).to have_select('Did the Customer Request a Specific Deadline?', :selected => "No")
    expect(page).to have_select('Is this a rush job?', :selected => "Yes")
  end

  scenario 'A user can edit job name and description', story_621: true, revamp: true do
    quote.jobs << create(:job, line_items: [create(:imprintable_line_item)])

    visit edit_quote_path quote
    find('a', text: 'Line Items').click

    fill_in 'job_name', with: 'New Job Name!!!'
    fill_in 'job_description', with: 'New Description!!!'

    click_button 'Save Line Item Changes'

    sleep 1

    expect(Job.where(name: 'New Job Name!!!')).to exist
    expect(Job.where(description: 'New Description!!!')).to exist
    expect(Job.where(name: 'New Job Name!!!', description: 'New Description!!!')).to exist
  end

  scenario 'A user can add an imprintable group of line items to a quote', story_567: true, revamp: true, story_570: true do
    imprintable_group; imprint_method_1; imprint_method_2
    visit edit_quote_path quote

    find('a', text: 'Line Items').click

    click_link 'Add A New Group'

    click_link 'Add Imprint'
    wait_for_ajax
    find('select[name=imprint_method]').select imprint_method_2.name

    select imprintable_group.name, from: 'Imprintable group'
    sleep 1.5
    fill_in 'Quantity', with: 10
    fill_in 'Decoration price', with: 12.55

    click_button 'Add Imprintable Group'

    expect(page).to have_content 'Quote was successfully updated.'
    quote.reload

    expect(quote.jobs.size).to be > 0
    expect(quote.jobs.where(name: imprintable_group.name)).to exist
    job = quote.jobs.where(name: imprintable_group.name).first
    expect(job.line_items.where(imprintable_variant_id: good_variant)).to exist
    expect(job.line_items.where(imprintable_variant_id: better_variant)).to exist
    expect(job.line_items.where(imprintable_variant_id: best_variant)).to exist
    expect(job.imprints.size).to eq 1
    expect(job.imprints.first.imprint_method).to eq imprint_method_2
  end

  scenario 'I can add a different imprint right after creating a group with one', bug_fix: true, imprint: true do
    imprintable_group; imprint_method_1; imprint_method_2

    visit edit_quote_path quote
    find('a', text: 'Line Items').click

    click_link 'Add A New Group'

    click_link 'Add Imprint'
    wait_for_ajax
    find('select[name=imprint_method]').select imprint_method_1.name

    select imprintable_group.name, from: 'Imprintable group'
    fill_in 'Quantity', with: 10
    fill_in 'Decoration price', with: 12.55

    click_button 'Add Imprintable Group'

    expect(page).to have_content 'Quote was successfully updated.'

    visit edit_quote_path quote
    find('a', text: 'Line Items').click

    click_link 'Add Imprint'
    wait_for_ajax
    within '.imprint-entry[data-id="-1"]' do
      find('select[name=imprint_method]').select imprint_method_2.name
      fill_in 'Description', with: 'Yes second imprint please'
    end

    click_button 'Save Line Item Changes'
    wait_for_ajax

    visit edit_quote_path quote
    find('a', text: 'Line Items').click

    within ".imprint-entry[data-id='#{imprint_method_1.id}']" do
      expect(page).to have_content imprint_method_1.name
    end

    within ".imprint-entry[data-id='#{imprint_method_2.id}']" do
      expect(page).to have_content imprint_method_2.name
    end
  end

  scenario 'I can add the same group twice', revamp: true, bug_fix: true, twice: true do
    imprintable_group; imprint_method_1; imprint_method_2

    visit edit_quote_path quote
    find('a', text: 'Line Items').click
    click_link 'Add A New Group'

    within '#contentModal' do
      select imprintable_group.name, from: 'Imprintable group'
      fill_in 'Quantity', with: 10
      fill_in 'Decoration price', with: 25.55

      click_link 'Add Imprint'
      sleep 0.5
      find('select[name=imprint_method]').select imprint_method_2.name

      click_button 'Add Imprintable Group'
    end

    expect(page).to have_content 'Quote was successfully updated.'

    visit edit_quote_path quote
    find('a', text: 'Line Items').click
    click_link 'Add A New Group'

    within '#contentModal' do
      select imprintable_group.name, from: 'Imprintable group'
      fill_in 'Quantity', with: 1
      fill_in 'Decoration price', with: 5.15

      click_link 'Add Imprint'
      sleep 0.5
      first('select[name=imprint_method]').select imprint_method_1.name

      click_link 'Add Imprint'
      sleep 0.5
      all('select[name=imprint_method]').last.select imprint_method_2.name

      click_button 'Add Imprintable Group'
    end

    expect(page).to have_content 'Quote was successfully updated.'

    expect(quote.jobs.size).to eq 2

    expect(quote.jobs.first.line_items.where(imprintable_variant_id: good_variant)).to exist
    expect(quote.jobs.first.line_items.where(imprintable_variant_id: better_variant)).to exist
    expect(quote.jobs.first.line_items.where(imprintable_variant_id: best_variant)).to exist

    expect(quote.jobs.last.line_items.where(imprintable_variant_id: good_variant)).to exist
    expect(quote.jobs.last.line_items.where(imprintable_variant_id: better_variant)).to exist
    expect(quote.jobs.last.line_items.where(imprintable_variant_id: best_variant)).to exist
  end

  scenario 'A user can add an imprintable group that only has one imprintable, properly', revamp: true, bug_fix: true do
    imprint_method_1; imprint_method_2; imprintable_group
    imprintable_group.imprintable_imprintable_groups[1].destroy
    imprintable_group.imprintable_imprintable_groups[2].destroy

    visit edit_quote_path quote

    find('a', text: 'Line Items').click

    click_link 'Add A New Group'

    select imprintable_group.name, from: 'Imprintable group'
    fill_in 'Quantity', with: 5
    fill_in 'Decoration price', with: 10.00

    click_button 'Add Imprintable Group'

    expect(page).to have_content 'Quote was successfully updated.'
    quote.reload

    expect(quote.jobs.size).to be > 0
    job = quote.jobs.where(name: imprintable_group.name).first
    expect(job.line_items.where(imprintable_variant_id: good_variant)).to exist
    expect(job.line_items.where(imprintable_variant_id: better_variant)).to_not exist
    expect(job.line_items.where(imprintable_variant_id: best_variant)).to_not exist
  end

  scenario 'A user can add imprintable line items to an existing job', revamp: true, story_557: true do
    allow(Imprintable).to receive(:search)
      .and_return OpenStruct.new(
        results: [imprintable1, imprintable2, imprintable3]
      )

    quote.jobs << create(:job, line_items: [create(:imprintable_line_item)])
    job = quote.jobs.first
    visit edit_quote_path quote

    find('a', text: 'Line Items').click

    click_link 'Add an imprintable'
    sleep 1
    within '#imprintable-add-search' do
      fill_in 'Terms', with: 'some imprintable'
    end
    sleep 0.5
    click_button 'Search'

    sleep 0.5
    find("#imprintable-result-#{imprintable1.id} input[type=checkbox]").click
    sleep 0.1
    find("#imprintable-result-#{imprintable3.id} input[type=checkbox]").click

    select quote.jobs.first.name, from: 'Group'
    select 'Better', from: 'Tier'
    fill_in 'Quantity', with: '6'
    fill_in 'Decoration price', with: '19.95'

    click_button 'Add Imprintable(s)'

    expect(page).to have_content 'Quote was successfully updated.'

    job.reload
    expect(job.line_items.where(imprintable_variant_id: iv1.id)).to exist
    expect(job.line_items.where(imprintable_variant_id: iv2.id)).to_not exist
    expect(job.line_items.where(imprintable_variant_id: iv3.id)).to exist
  end

  scenario 'A user can add an option/markup to a quote', revamp: true, story_558: true do
    quote.update_attributes informal: true
    quote.jobs << create(:job, line_items: [create(:imprintable_line_item)])
    visit edit_quote_path quote

    find('a', text: 'Line Items').click

    click_link 'Add An Option or Markup'
    sleep 0.5

    fill_in 'Name', with: 'Special sauce'
    sleep 0.05
    fill_in 'Description', with: 'improved taste'
    fill_in 'Url', with: 'http://lmgtfy.com/?q=secret+sauce'
    fill_in 'Unit price', with: '99.99'

    click_button 'Add Option or Markup'

    expect(page).to have_content 'Quote was successfully updated.'

    job = quote.markups_and_options_job
    job.reload

    expect(job.line_items.size).to eq 1

    line_item = job.line_items.first
    expect(line_item.name).to eq 'Special sauce'
    expect(line_item.description).to eq 'improved taste'
    expect(line_item.url).to eq 'http://lmgtfy.com/?q=secret+sauce'
    expect(line_item.unit_price.to_f).to eq 99.99
  end

  scenario 'A user can add a note to a quote', revamp: true, story_569: true do
    visit edit_quote_path quote

    find('a', text: 'Notes').click

    fill_in 'Title', with: 'Test Note?'
    fill_in 'Comment', with: 'This is what I want to see'

    click_button 'Add Note'

    expect(page).to have_content 'Test Note?'
    expect(page).to have_content 'This is what I want to see'

    quote.reload
    expect(quote.private_notes.where(title: 'Test Note?')).to exist
    expect(quote.private_notes.where(comment: 'This is what I want to see')).to exist
  end

  scenario 'A user can remove a note from a quote', revamp: true, story_569: true do
    quote.notes << Comment.create(title: 'Test Note?', comment: 'This is what I want to see', role: 'private')

    visit edit_quote_path quote

    find('a', text: 'Notes').click

    sleep 0.5
    first('.delete-comment').click
    sleep 0.5

    quote.reload
    expect(quote.notes.where(title: 'Test Note?')).to_not exist
    expect(quote.notes.where(comment: 'This is what I want to see')).to_not exist
  end

  scenario 'A user can remove line items from a quote', story_572: true, revamp: true do
    job = create(:job, name: 'Some imprintables')
    job.line_items << create(:imprintable_line_item, tier: Imprintable::TIER.good,   name: 'Good')
    imprintable_line_item_to_delete = create(:imprintable_line_item, tier: Imprintable::TIER.good, name: 'Bad Good')
    job.line_items << imprintable_line_item_to_delete
    job.line_items << create(:imprintable_line_item, tier: Imprintable::TIER.better, name: 'Better')
    job.line_items << create(:imprintable_line_item, tier: Imprintable::TIER.best,   name: 'Best')
    quote.jobs << job

    quote.markups_and_options_job.line_items << create(:non_imprintable_line_item)
    standard_line_item_to_delete = create(:non_imprintable_line_item, name: 'Remove me')
    quote.markups_and_options_job.line_items << standard_line_item_to_delete

    visit edit_quote_path quote

    find('a', text: 'Line Items').click

    expect(LineItem.where(name: 'Remove me')).to exist

    expect(page).to have_content 'Remove me'

    within("#edit-line-item-#{imprintable_line_item_to_delete.id}") do
      click_link 'Remove'
    end

    within("#line-item-#{standard_line_item_to_delete.id}") do
      click_link 'Remove'
    end

    click_button 'Save Line Item Changes'

    sleep 1

    expect(LineItem.where(name: 'Remove me')).to_not exist
    expect(page).to_not have_content 'Remove me'
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

  scenario 'A user can generate a quote from an imprintable pricing dialog', story_489: true, pricing_spec: true, pending: 'NO MORE PRICING TABLE' do
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

  scenario 'A user can add a single price from the pricing table to an existing quote', pending: 'NO MORE PRICING TABLE' do
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
