require 'spec_helper'
include ApplicationHelper
require 'email_spec'
require_relative '../../app/controllers/jobs_controller'

feature 'Quotes management', slow: true, quote_spec: true, redo: 3 do
  context 'As as logged in user' do
    given!(:valid_user) { create(:alternate_user, insightly_api_key: "insight") }
    background(:each) { sign_in_as(valid_user) }

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

    given(:standard_line_item_1) { create(:non_imprintable_line_item) }
    given(:standard_line_item_2) { create(:non_imprintable_line_item) }
    given(:standard_line_item_3) { create(:non_imprintable_line_item) }

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

    scenario 'I can see a list of quotes' do
      visit root_path
      unhide_dashboard
      click_link 'quotes_list'
      click_link 'quotes_path_link'
      expect(page).to have_content('View and edit quotes')
    end

    context 'with a freshdesk ticket associated with a quote', story_639: true do
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

      scenario 'I can set up an email for freshdesk', js: true do
        quote.freshdesk_ticket_id = 1
        quote.save!
        visit edit_quote_path quote.id
        click_link 'Sales'
        click_link 'Prepare for FreshDesk'
        fill_in 'Body', with: '<div class= "wumbo">Wumbo</div>'
        sleep 1
        click_button 'Prepare for Freshdesk'
        expect(page).to have_css('.wumbo')
      end
    end

    context 'without an insightly api key' do
      given!(:user) { create(:alternate_user) }
      background(:each) { sign_in_as(user) }

      scenario 'I create a quote with new contact information', edit: true, js: true do
        visit new_quote_path

        expect {
          within('#new_contact_content') do
            fill_in 'First name', with: 'Capy'
            fill_in 'Last name', with: 'Bara'
            fill_in 'E-mail', with: 'test@spec.com'
            fill_in 'Phone', with: '555-555-1212'
          end

          click_button 'Next'
          sleep 0.5

          fill_in 'Quote Name', with: 'A uniquely searchable quote'
          find('#quote_quote_source').find("option[value='Other']").click
          sleep 0.5
          click_button 'Next'
          sleep 0.5
          click_button 'Submit'
        }.to change{ Quote.count }.by(1)

        sleep 0.5
        expect(page).to have_content 'Quote was successfully created.'
        quote = Quote.find_by(name: 'A uniquely searchable quote')
        expect(value_time(quote.estimated_delivery_date)).to eq(value_time(fourteen_days_from_now_at_5))
        expect(value_time(quote.valid_until_date)).to eq(value_time(thirty_days_from_now_at_5))
      end

      scenario 'Error reports turn the page to the first on on which there is an error', js: true, story_491: true do
        visit new_quote_path
        within('#new_contact_content') do
          fill_in 'E-mail', with: 'test@spec.com'
          fill_in 'Phone', with: '555-555-1212'
        end

        click_button 'Next'
        sleep 0.5

        click_button 'Next'
        sleep 0.5
        click_button 'Submit'

        sleep 0.5
        find('button[data-dismiss="modal"]').click

        expect(page).to have_selector(".current[data-step='2']")
      end

      context 'with existing contacts' do
        let!(:contact){ create(:crm_contact) }

        before do
          allow_any_instance_of(SunspotMatchers::SunspotSearchSpy).to\
          receive(:results) { Kaminari.paginate_array(Crm::Contact.all.to_a).page(1).per(10) }

          allow_any_instance_of(Kaminari::PaginatableArray).to\
          receive(:total_entries) { Crm::Contact.count }
        end

        scenario 'I can create a quote using an existing contact', js: true, no_ci: true do
          visit new_quote_path

          expect {
            click_link 'Search Existing Contacts'
            fill_in 'contact_search_terms', with: 'User name'
            click_link 'Search Contacts'
            sleep 0.5
            choose contact.full_name

            click_button 'Next'
            sleep 0.5

            fill_in 'Quote Name', with: 'A uniquely searchable quote'
            find('#quote_quote_source').find("option[value='Other']").click
            sleep 1
            click_button 'Next'
            sleep 0.5

            sleep 1.5 if ci?
            click_button 'Submit'
          }.to change{ Quote.count }.by(1)

          sleep 1
          expect(page).to have_content 'Quote was successfully created.'

          sleep 0.5
          expect(page).to have_content 'Quote was successfully created.'
          quote = Quote.find_by(name: 'A uniquely searchable quote')
          expect(value_time(quote.estimated_delivery_date)).to eq(value_time(fourteen_days_from_now_at_5))
          expect(value_time(quote.valid_until_date)).to eq(value_time(thirty_days_from_now_at_5))
        end

      end
    end

    context 'with an existing quote' do
      scenario 'I can mark as "sent to customer"', js: false do
        visit edit_quote_path quote
        click_link "Mark as sent to customer"
        within('.quote-state') do
          expect(page).to have_content("Sent to customer")
        end
      end

      scenario 'I can mark as "lost"', js: false do
        visit edit_quote_path quote
        click_link "Mark as lost"
        within('.quote-state') do
          expect(page).to have_content("Lost")
        end
      end

      scenario 'I can edit a quote', story_151: true, story_692: true, js: true do
        visit edit_quote_path quote
        click_link 'Details'
        fill_in 'Quote Name', with: 'New Quote Name'
        select 'No', from: 'Informal quote?'
        select 'No', from: 'Did the Customer Request a Specific Deadline?'
        select 'Yes', from: 'Is this a rush job?'
        click_button 'Save'

        within('.quote-edit-title') do
          expect(page).to have_content 'New Quote Name'
        end

        close_flash_modal
        click_link 'Details'
        expect(page).to have_select('Informal quote?', selected: "No")
        expect(page).to have_select('Did the Customer Request a Specific Deadline?', selected: "No")
        expect(page).to have_select('Is this a rush job?', selected: "Yes")
      end

      scenario 'When editing a quote, Insightly forms dynamically changed fields', story_598: true, js: true do
        allow_any_instance_of(InsightlyHelper).to receive(:insightly_available?).and_return true
        allow_any_instance_of(InsightlyHelper).to receive(:insightly_categories).and_return []
        allow_any_instance_of(InsightlyHelper).to receive(:insightly_pipelines).and_return []
        allow_any_instance_of(InsightlyHelper).to receive(:insightly_opportunity_profiles).and_return []
        allow_any_instance_of(InsightlyHelper).to receive(:insightly_bid_tiers).and_return ["unassigned", "Tier 1  ($1 - $249)", "Tier 2  ($250 - $499)", "Tier 3  ($500 - $999)", "Tier 4  ($1000 and up)"]

        visit new_quote_path
        click_button 'Next'
        click_button 'Next'
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

      scenario 'I can add an imprintable group of line items to a quote', no_ci: true, js: true do
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
        expect(job.line_items.where(imprintable_object_id: good_imprintable.id)).to exist
        expect(job.line_items.where(imprintable_object_id: better_imprintable.id)).to exist
        expect(job.line_items.where(imprintable_object_id: best_imprintable.id)).to exist
        expect(job.imprints.size).to eq 1
        expect(job.imprints.first.imprint_method).to eq imprint_method_2
      end

      scenario 'When I add an imprintable it is tracked in the timeline', no_ci: true, js: true do
        PublicActivity.with_tracking do
          allow(Imprintable).to receive(:search)
                                  .and_return OpenStruct.new(
                                                results: [imprintable1, imprintable2, imprintable3]
                                              )

          quote.jobs << create(:quote_job, line_items: [create(:imprintable_quote_line_item)])
          job = quote.jobs.first
          visit edit_quote_path(quote)

          click_link 'Line Items'

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

          click_link 'Timeline'

          expect(page).to have_content '19.95'
          expect(page).to have_content '6'
        end

      end

      scenario 'When I add a note it is tracked in the timeline', story_600: true, js: true  do
        PublicActivity.with_tracking do
          visit edit_quote_path quote
          click_link 'Notes'
          fill_in 'Title', with: 'Hi There'
          fill_in 'Comment', with: 'Comment'
          click_button 'Add Note'
          wait_for_ajax
          click_link 'Timeline'
          visit edit_quote_path quote
          click_link 'Timeline'
          expect(page).to have_link 'Hi There'
        end
      end

      scenario 'When I add a markup/upcharge it is tracked in the timeline', js: true, story_600: true, story_692: true do
        PublicActivity.with_tracking do
          imprintable_group; imprint_method_1; imprint_method_2
          visit edit_quote_path quote
          click_link 'Line Items'
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
          click_link 'Add An Option or Markup'
          fill_in 'Name', with: 'Mr. Money'
          fill_in 'line_item[description]', with: 'Cash'
          fill_in 'Url', with: 'www.mrmoney.com'
          fill_in 'Unit price', with: '999'
          click_button 'Add Option or Markup'
          sleep 2
          click_button 'OK'
          visit edit_quote_path quote
          click_link 'Timeline'
          sleep 2
          expect(page).to have_content 'Mr. Money'
          expect(page).to have_content 'Cash'
          expect(page).to have_content 'www.mrmoney.com'
          expect(page).to have_content '999'
        end
      end

      scenario 'When I add line item groups it is tracked in the timeline', js: true, story_600: true do
        PublicActivity.with_tracking do
          imprintable_group; imprint_method_1; imprint_method_2
          visit edit_quote_path quote
          click_link 'Line Items'
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
          click_link 'Timeline'

          expect(page).to have_content '10'
          expect(page).to have_content '12.55'
        end
      end

      scenario 'When I change an existing line item it is tracked in the timeline', js: true, story_600: true do
        PublicActivity.with_tracking do
          imprintable_group; imprint_method_1; imprint_method_2

          visit edit_quote_path quote
          click_link 'Line Items'
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

          click_link 'Timeline'

          expect(page).to have_content '10'
          expect(page).to have_content '12.55'
        end
      end

      scenario 'I can add a different imprint right after creating a group with one', js: true, no_ci: true, bug_fix: true, imprint: true do
        imprintable_group; imprint_method_1; imprint_method_2

        visit edit_quote_path quote
        click_link 'Line Items'
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

      scenario 'I can add the same group twice', js: true, bug_fix: true, twice: true do
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

        expect(quote.jobs.first.line_items.where(imprintable_object_id: good_imprintable.id)).to exist
        expect(quote.jobs.first.line_items.where(imprintable_object_id: better_imprintable.id)).to exist
        expect(quote.jobs.first.line_items.where(imprintable_object_id: best_imprintable.id)).to exist

        expect(quote.jobs.last.line_items.where(imprintable_object_id: good_imprintable.id)).to exist
        expect(quote.jobs.last.line_items.where(imprintable_object_id: better_imprintable.id)).to exist
        expect(quote.jobs.last.line_items.where(imprintable_object_id: best_imprintable.id)).to exist
      end

      scenario 'I can add  an imprintable group that only has one imprintable, properly', js: true, bug_fix: true do
        imprint_method_1; imprint_method_2; imprintable_group
        imprintable_group.imprintable_imprintable_groups[1].destroy
        imprintable_group.imprintable_imprintable_groups[2].destroy

        visit edit_quote_path quote
        click_link 'Line Items'
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
        expect(job.line_items.where(imprintable_object_id: good_imprintable.id)).to exist
        expect(job.line_items.where(imprintable_object_id: better_imprintable.id)).to_not exist
        expect(job.line_items.where(imprintable_object_id: best_imprintable.id)).to_not exist
      end

      scenario 'I can add imprintable line items to an existing job', js: true, revamp: true, story_557: true do
        allow(Imprintable).to receive(:search)
                                .and_return OpenStruct.new(
                                              results: [imprintable1, imprintable2, imprintable3]
                                            )

        quote.jobs << create(:quote_job, line_items: [create(:imprintable_quote_line_item)])
        job = quote.jobs.first
        visit edit_quote_path quote
        click_link 'Line Items'
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
        expect(job.line_items.where(imprintable_object_id: imprintable1.id)).to exist
        expect(job.line_items.where(imprintable_object_id: imprintable2.id)).to_not exist
        expect(job.line_items.where(imprintable_object_id: imprintable3.id)).to exist
      end

      scenario 'I cannot submit adding an imprintable without selecting anything', js: true, revamp: true, story_730: true do
        quote.jobs << create(:quote_job, line_items: [create(:imprintable_quote_line_item)])
        job = quote.jobs.first
        visit edit_quote_path quote
        click_link 'Line Items'
        click_link 'Add an imprintable'
        sleep 1

        select quote.jobs.first.name, from: 'Group'
        select 'Better', from: 'Tier'
        fill_in 'Quantity', with: '6'
        fill_in 'Decoration price', with: '19.95'

        click_button 'Add Imprintable(s)'

        expect(page).to have_content 'Please mark at least one imprintable to be added.'
      end

      scenario 'I can add an imprintable without specifying quantity or decoration price', js: true, story_729: true do
        allow(Imprintable).to receive(:search)
                                .and_return OpenStruct.new(
                                              results: [imprintable1, imprintable2, imprintable3]
                                            )

        quote.jobs << create(:quote_job, line_items: [create(:imprintable_quote_line_item, quantity: 20, decoration_price: 10)])
        job = quote.jobs.first
        visit edit_quote_path quote

        click_link 'Line Items'
        click_link 'Add an imprintable'
        sleep 1
        within '#imprintable-add-search' do
          fill_in 'Terms', with: 'some imprintable'
        end
        sleep 0.5
        click_button 'Search'

        sleep 0.5
        find("#imprintable-result-#{imprintable1.id} input[type=checkbox]").click
        sleep 0.5

        select quote.jobs.first.name, from: 'Group'
        select 'Better', from: 'Tier'

        click_button 'Add Imprintable(s)'

        sleep 1 if ci?
        expect(page).to have_content 'Quote was successfully updated.'

        job.reload
        expect(job.line_items.where(imprintable_object_id: imprintable1.id)).to exist
        expect(job.line_items.where(imprintable_object_id: imprintable1.id, quantity: 20, decoration_price: 10)).to exist
      end

      scenario 'I can add an option/markup to a quote', js: true, revamp: true, story_558: true, story_692: true do
        quote.update_attributes informal: true
        quote.jobs << create(:quote_job, line_items: [create(:imprintable_quote_line_item)])
        visit edit_quote_path quote
        click_link 'Line Items'
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

        sleep 1
        expect(job.line_items.size).to eq 1

        line_item = job.line_items.first
        expect(line_item.name).to eq 'Special sauce'
        expect(line_item.description).to eq 'improved taste'
        expect(line_item.url).to eq 'http://lmgtfy.com/?q=secret+sauce'
        expect(line_item.unit_price.to_f).to eq 99.99
      end

      scenario 'If I add an optional option/markup without a price, I am told to enter a price', js: true, story_705: true do
        quote.update_attributes informal: true
        quote.jobs << create(:quote_job, line_items: [create(:imprintable_quote_line_item)])
        visit edit_quote_path quote

        click_link 'Line Items'
        click_link 'Add An Option or Markup'
        sleep 0.5

        fill_in 'Name', with: 'Special sauce'
        sleep 0.05
        fill_in 'Description', with: 'improved taste'
        fill_in 'Url', with: 'http://lmgtfy.com/?q=secret+sauce'

        click_button 'Add Option or Markup'
        sleep 1
        expect(page).to_not have_content 'Quote was successfully updated.'
      end

      scenario 'I can sort options and markups on a quote', js: true, revamp: true, story_797: true do
        quote.jobs << create(:quote_job, line_items: [create(:imprintable_quote_line_item)])
        quote.markups_and_options_job.line_items << standard_line_item_1
        quote.markups_and_options_job.line_items << standard_line_item_2
        quote.markups_and_options_job.line_items << standard_line_item_3

        visit edit_quote_path quote
        find('a', text: 'Line Items').click

        simulate_drag_sortable_on page
        simulate_drag_sortable(".option-and-markup-line-items > :first-child", move: 1)
        expect(page).to have_selector(".option-and-markup-line-items > :nth-child(2) #line-item-#{standard_line_item_1.id}")

        visit edit_quote_path quote
        find('a', text: 'Line Items').click

        expect(page).to have_selector(".option-and-markup-line-items > :nth-child(2) #line-item-#{standard_line_item_1.id}")
      end

      scenario 'I can add a note to a quote', js: true, revamp: true, story_569: true do
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

      scenario 'I can remove a note from a quote', js: true, revamp: true, story_569: true do
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

      scenario 'I can remove line items from a quote', js: true, no_ci: true, story_572: true, revamp: true do
        job = create(:quote_job, name: 'Some imprintables')
        job.line_items << create(:imprintable_quote_line_item, tier: Imprintable::TIER.good,   name: 'Good')
        imprintable_line_item_to_delete = create(:imprintable_quote_line_item, tier: Imprintable::TIER.good, name: 'Bad Good')
        job.line_items << imprintable_line_item_to_delete
        job.line_items << create(:imprintable_quote_line_item, tier: Imprintable::TIER.better, name: 'Better')
        job.line_items << create(:imprintable_quote_line_item, tier: Imprintable::TIER.best,   name: 'Best')
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

      scenario 'I can add a line item from a template', js: true, no_ci: true, retry: 3, story_494: true do
        template = create(:line_item_template, name: 'nice')
        allow(LineItemTemplate).to receive(:search)
                                     .and_return double(
                                                   'Line Item Template Search',
                                                   results: [template]
                                                 )
        quote.update_attributes informal: true
        quote.jobs << create(:quote_job, line_items: [create(:imprintable_quote_line_item)])

        visit edit_quote_path quote
        find('a', text: 'Line Items').click

        click_link 'Add An Option or Markup'
        sleep 0.5

        find('#search-templates').set 'nice'
        click_button 'Search'

        sleep 1
        expect(page).to have_content 'nice'
        expect(page).to have_content template.description

        click_link 'Use'
        sleep 2

        click_button 'Add Option or Markup'
        sleep 2
        expect(page).to have_content 'Quote was successfully updated.'
        expect(quote.reload.markups_and_options_job.line_items.where(name: 'nice')).to exist
      end

      context 'if I want to change contact info' do
        let!(:a_different_contact){ create(:crm_contact) }

        before do
          allow_any_instance_of(SunspotMatchers::SunspotSearchSpy).to\
          receive(:results) { Kaminari.paginate_array(Crm::Contact.all.to_a).page(1).per(10) }

          allow_any_instance_of(Kaminari::PaginatableArray).to\
          receive(:total_entries) { Crm::Contact.count }

          visit edit_quote_path(quote)
          click_link 'Details'
          sleep(0.5)
        end

        scenario 'I can edit the existing contact', js: true do
          click_link 'Edit Contact'
          within('#edit_contact_content') do
            fill_in 'First name', with: 'Simba'
          end
          click_button 'Save'
          sleep 1
          expect(quote.reload.contact.first_name).to eq('Simba')
        end

        scenario 'I can change the contact by searching for a new one', js: true, no_ci: true do
          click_link 'Change Contact'
          click_link 'Search Existing Contacts'
          fill_in 'contact_search_terms', with: 'User name'
          click_link 'Search Contacts'
          sleep 0.5
          choose a_different_contact.full_name
          click_button 'Save'
          expect(quote.reload.contact).to eq(a_different_contact)
        end

        scenario 'I can change the contact by creating a new one', js: true do
          old_contact = quote.contact
          click_link 'Change Contact'
          expect{
            within('#new_contact_content') do
              fill_in 'First name', with: 'Capy'
              fill_in 'Last name', with: 'Bara'
              fill_in 'E-mail', with: 'test@spec.com'
              fill_in 'Phone', with: '555-555-1212'
            end
            click_button 'Save'
          }.to change{ Crm::Contact.count }.by(1)
          expect(quote.reload.contact).to_not eq(old_contact)
        end
      end
    end
  end
end
