require 'spec_helper'
include ApplicationHelper
require 'email_spec'
require_relative '../../app/controllers/jobs_controller'

feature 'Quotes management', quote_spec: true, js: true, retry: 2 do
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
  end

  context 'A user can prepare for freshdesk', story_639: true, js: true do
     given!(:fd_ticket) do   {
      "created_at" => "Thu, 21 May 2015 15:57:32 EDT -04:00",  
      "notes" => 
      [
        {"note" => {"body_html" => "<p></p><blockquote class=\"freshdesk_quote\">wasabi451</blockquote>", "created_at" => "aba" }} 
      ]
     }
     end

    background(:each) do 
      allow_any_instance_of(Quote).to receive(:no_ticket_id_entered?).and_return false
      allow_any_instance_of(Quote).to receive(:no_fd_login?).and_return false
      allow_any_instance_of(Quote).to receive(:has_freshdesk_ticket?).and_return true
      allow_any_instance_of(Quote).to receive(:get_freshdesk_ticket).and_return fd_ticket
      allow(fd_ticket).to receive(:helpdesk_ticket).and_return fd_ticket
      allow_any_instance_of(ApplicationHelper).to receive(:parse_freshdesk_time).and_return Time.now
    end

    scenario 'A user can set up an email for freshdesk' do
      quote.freshdesk_ticket_id = 1
      quote.save!
      visit edit_quote_path quote.id
      click_link 'Actions'
      click_link 'Prepare for FreshDesk'
      fill_in 'Body', with: '<div class= "wumbo">Wumbo</div>'
      sleep 1
      click_button 'Prepare for Freshdesk'
      expect(page).to have_css('.wumbo')
    end
  end

  context 'without an insightly api key' do
    given!(:user) { create(:alternate_user) }
    background(:each) { login_as(user) }

    scenario 'A user can create a quote', edit: true, wumbo: true do
      visit root_path
      unhide_dashboard

      click_link 'quotes_list'
      click_link 'new_quote_link'

      fill_in 'Email', with: 'test@spec.com'
      fill_in 'First Name', with: 'Capy'
      fill_in 'Last Name', with: 'Bara'
      click_button 'Next'
      sleep 0.5

      fill_in 'Quote Name', with: 'Quote Name'
      find('#quote_quote_source').find("option[value='Other']").click
      sleep 1
      fill_in 'Quote Valid Until Date', with: (2.days.from_now).strftime('%m/%d/%Y %I:%M %p')
      fill_in 'Estimated Delivery Date', with: (1.days.from_now).strftime('%m/%d/%Y %I:%M %p')
      click_button 'Next'
      sleep 0.5

      click_button 'Submit'

      sleep 1
      expect(page).to have_content 'Quote was successfully created.'
    end
  end

  scenario 'A user can visit the edit quote page', edit: true do
    visit quotes_path
    find('i.fa.fa-edit').click
    expect(current_path).to eq(edit_quote_path quote.id)
  end

  scenario 'A user can edit a quote', edit: true, story_692: true do
    visit edit_quote_path quote.id
    find('a', text: 'Details').click
    fill_in 'Quote Name', with: 'New Quote Name'
    click_button 'Save'
    visit current_path
    expect(current_path).to eq(edit_quote_path quote.id)
    expect(quote.reload.name).to eq('New Quote Name')
  end

  scenario 'Insightly forms dynamically changed fields', edit: true do
    allow_any_instance_of(InsightlyHelper).to receive(:insightly_available?).and_return true
    allow_any_instance_of(InsightlyHelper).to receive(:insightly_categories).and_return [] 
    allow_any_instance_of(InsightlyHelper).to receive(:insightly_pipelines).and_return [] 
    allow_any_instance_of(InsightlyHelper).to receive(:insightly_opportunity_profiles).and_return [] 
    allow_any_instance_of(InsightlyHelper).to receive(:insightly_bid_tiers).and_return ["unassigned", "Tier 1 ($1 - $249)", "Tier 2 ($250 - $499)", "Tier 3 ($500 - $999)", "Tier 4 ($1000 and up)"] 

    visit new_quote_path
    click_button 'Next' 
    click_button 'Next' 
   # select "Email", :from => "Category"
    expect(page).to have_select('Bid Tier', :selected => "unassigned")
    fill_in 'Estimated Quote', with: '200'
    fill_in 'Opportunity ID', with: '200'
    expect(page).to have_field("Bid Amount", :with => "200") 
    expect(page).to have_select('Bid Tier', :selected => "Tier 1 ($1 - $249)")
    fill_in 'Estimated Quote', with:'275'
    fill_in 'Opportunity ID', with: '300'
    expect(page).to have_field("Bid Amount", :with => '275')
    expect(page).to have_select('Bid Tier', :selected => "Tier 2 ($250 - $499)")
    fill_in 'Estimated Quote', with:'550'
    fill_in 'Opportunity ID', with: '400'
    expect(page).to have_field("Bid Amount", :with => '550')
    expect(page).to have_select('Bid Tier', :selected => "Tier 3 ($500 - $999)")
    fill_in 'Estimated Quote', with:'2000'
    fill_in 'Opportunity ID', with: '500'
    expect(page).to have_field("Bid Amount", :with => '2000')
    expect(page).to have_select('Bid Tier', :selected => "Tier 4 ($1000 and up)")
  end

  scenario 'A users options are properly saved', edit: true, story_692: true do
    visit edit_quote_path quote.id
    click_link 'Details'
    select 'No', :from => "Informal quote?" 
    select 'No', :from => "Did the Customer Request a Specific Deadline?" 
    select 'Yes', :from => "Is this a rush job?" 
    click_button 'Save'
    visit current_path
    click_link 'Details'
    expect(page).to have_select('Informal quote?', :selected => "No")
    expect(page).to have_select('Did the Customer Request a Specific Deadline?', :selected => "No")
    expect(page).to have_select('Is this a rush job?', :selected => "Yes")
  end

  scenario 'A user can add an imprintable group of line items to a quote', no_ci: true, story_567: true, revamp: true, story_570: true do
    imprintable_group; imprint_method_1; imprint_method_2
    visit edit_quote_path quote

    find('a', text: 'Line Items').click

    click_link 'Add A New Group'

    click_link 'Add Imprint'
    sleep 1
    find('select[name=imprint_method]').select imprint_method_2.name

    select imprintable_group.name, from: 'Imprintable group'
    fill_in 'Quantity', with: 10
    fill_in 'Decoration price', with: 12.55

    sleep 1
    click_button 'Add Imprintable Group'

    sleep 1 if ci?
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

  scenario 'Adding an imprintable is tracked by public activity', no_ci: true, story_600: true do
    PublicActivity.with_tracking do
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
      click_button 'OK'
      visit edit_quote_path quote
      
      expect(page).to have_content '19.95'
      expect(page).to have_content '6'
    end

  end

  scenario 'Adding a note is tracked by public activity', story_600: true do 
    PublicActivity.with_tracking do
      visit edit_quote_path quote
      click_link 'Notes' 
      fill_in 'Title', with: 'Hi There' 
      fill_in 'Comment', with: 'Comment' 
      click_button 'Add Note'
      wait_for_ajax
      click_link 'Timeline' 
      visit edit_quote_path quote
      expect(page).to have_link 'Hi There'
    end
  end
    
  scenario 'Adding a markup/upcharge is tracked by public activity', no_ci: true, retry: true, story_600: true, story_692: true do 
    PublicActivity.with_tracking do
      imprintable_group; imprint_method_1; imprint_method_2
      visit edit_quote_path quote

      find('a', text: 'Line Items').click

      click_link 'Add A New Group'

      click_link 'Add Imprint'
      sleep 1
      find('select[name=imprint_method]').select imprint_method_2.name

      select imprintable_group.name, from: 'Imprintable group'
      fill_in 'Quantity', with: 10
      fill_in 'Decoration price', with: 12.55

      sleep 1
      click_button 'Add Imprintable Group'
      click_button 'OK'
      visit edit_quote_path quote
      click_link 'Line Items' 
      click_link "Add An Option or Markup"
      fill_in 'Name', with: 'Mr. Money' 
      fill_in 'line_item[description]', with: 'Cash' 
      fill_in 'Url', with: 'www.mrmoney.com' 
      fill_in 'Unit price', with: '999' 
      click_button 'Add Option or Markup'
      sleep 2
      click_button 'OK'
      visit edit_quote_path quote
      expect(page).to have_content 'Mr. Money'
      expect(page).to have_content 'Cash' 
      expect(page).to have_content 'www.mrmoney.com' 
      expect(page).to have_content '999' 
    end
  end

  scenario 'Adding a line item groups is tracked by public activity', no_ci: true, story_600: true do
    PublicActivity.with_tracking do
      imprintable_group; imprint_method_1; imprint_method_2
      visit edit_quote_path quote

      find('a', text: 'Line Items').click

      click_link 'Add A New Group'

      click_link 'Add Imprint'
      sleep 1.5
      find('select[name=imprint_method]').select imprint_method_2.name

      select imprintable_group.name, from: 'Imprintable group'
      fill_in 'Quantity', with: 10
      fill_in 'Decoration price', with: 12.55

      click_button 'Add Imprintable Group'
      sleep 1.5
      click_button 'OK'
      sleep 1.5
      visit edit_quote_path quote

      expect(page).to have_content '10'
      expect(page).to have_content '12.55'
    end
  end

  scenario 'Changing existing line items is tracked', retry: 3, story_600: true do
    PublicActivity.with_tracking do
      imprintable_group; imprint_method_1; imprint_method_2

      visit edit_quote_path quote
      find('a', text: 'Line Items').click

      click_link 'Add A New Group'

      click_link 'Add Imprint'
      sleep 2
      find('select[name=imprint_method]').select imprint_method_1.name

      select imprintable_group.name, from: 'Imprintable group'
      fill_in 'Quantity', with: 10
      fill_in 'Decoration price', with: 12.55

      click_button 'Add Imprintable Group'

      sleep 1 if ci?
      expect(page).to have_content 'Quote was successfully updated.'
      click_button 'OK'
      visit edit_quote_path quote
      find('a', text: 'Line Items').click

      click_link 'Add Imprint'
      sleep 1
      within '.imprint-entry[data-id="-1"]' do
        find('select[name=imprint_method]').select imprint_method_2.name
        fill_in 'Description', with: 'Yes second imprint please'
      end
      sleep 1
      click_button 'Save Line Item Changes'

      visit edit_quote_path quote

      expect(page).to have_content '10'
      expect(page).to have_content '12.55'
    end
  end

  scenario 'I can add a different imprint right after creating a group with one', no_ci: true, retry: 2, bug_fix: true, imprint: true, story_692: true do
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

    sleep 2
    click_button 'Add Imprintable Group'

    sleep 1 if ci?
    expect(page).to have_content 'Quote was successfully updated.'

    visit edit_quote_path quote
    find('a', text: 'Line Items').click

    click_link 'Add Imprint'
    sleep 1
    within '.imprint-entry[data-id="-1"]' do
      find('select[name=imprint_method]').select imprint_method_2.name
      fill_in 'Description', with: 'Yes second imprint please'
    end

    click_button 'Save Line Item Changes'
    sleep 1

    visit edit_quote_path quote
    find('a', text: 'Line Items').click

    within ".imprint-entry[data-id='#{imprint_method_1.id}']" do
      expect(page).to have_content imprint_method_1.name
    end

    within ".imprint-entry[data-id='#{imprint_method_2.id}']" do
      expect(page).to have_content imprint_method_2.name
    end
  end

  scenario 'I can add the same group twice', no_ci: true, retry: 2, revamp: true, bug_fix: true, twice: true do
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

    sleep 2 if ci?
    expect(page).to have_content 'Quote was successfully updated.'

    visit edit_quote_path quote
    find('a', text: 'Line Items').click
    click_link 'Add A New Group'

    within '#contentModal' do
      select imprintable_group.name, from: 'Imprintable group'
      fill_in 'Quantity', with: 1
      fill_in 'Decoration price', with: 5.15

      click_link 'Add Imprint'
      sleep 1
      first('select[name=imprint_method]').select imprint_method_1.name

      click_link 'Add Imprint'
      sleep 1
      all('select[name=imprint_method]').last.select imprint_method_2.name

      click_button 'Add Imprintable Group'
    end

    sleep 2 if ci?
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

    sleep 1 if ci?
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

    sleep 1 if ci?
    expect(page).to have_content 'Quote was successfully updated.'

    job.reload
    expect(job.line_items.where(imprintable_variant_id: iv1.id)).to exist
    expect(job.line_items.where(imprintable_variant_id: iv2.id)).to_not exist
    expect(job.line_items.where(imprintable_variant_id: iv3.id)).to exist
  end

  scenario 'A user can add an option/markup to a quote', revamp: true, story_558: true, story_692: true do
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
    sleep 1
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
    sleep 1 if ci?
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
end
