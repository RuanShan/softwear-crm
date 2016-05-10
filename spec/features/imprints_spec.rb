require 'spec_helper'
include GeneralHelpers

feature 'Imprints Management', slow: true, imprint_spec: true, js: true do
  given!(:valid_user) { create(:user) }
  background(:each) { sign_in_as valid_user }

  given!(:order) { create :order_with_job }
  given(:job) { order.jobs.first }

  -> (t,&b) {b.call(t)}.call(
       [%w(Digital Screen Embroidery Name/Number),
        %w(Front   Lower  Wherever Somewhere)]) do |name|
    4.times do |n|
      let!("imprint_method#{n+1}") do
        create(:valid_imprint_method, name: name.first[n], name_number: name.first[n] == 'Name/Number')
      end
      let!("print_location#{n+1}") do
        create(:valid_print_location, name: name[1][n], imprint_method_id: send("imprint_method#{n+1}").id)
      end
    end
  end

  given(:imprint) { create(:blank_imprint, job_id: job.id, print_location_id: print_location1.id) }

  scenario 'user can add a new imprint to a job', retry: 3 do
    visit edit_order_path(order.id, anchor: 'jobs')
    wait_for_ajax

    sleep 1
    first('.add-imprint').click
    sleep 1
    select2 imprint_method2.name, from: "#imprint_method_select_-1"
    sleep 1
    select2 print_location2.name, from: 'Print location'
    expect(all('.editing-imprint').count).to be > 1
    sleep 1
    find('.update-imprints').click
    sleep 1.5
    expect(Imprint.where(job_id: job.id, print_location_id: print_location2.id)).to exist
  end

  scenario 'user can create an imprint that does not require artwork' do
    imprint_method2.update_column :requires_artwork, false
    expect(order.artwork_state).to eq 'pending_artwork_requests'

    visit edit_order_path(order.id, anchor: 'jobs')
    wait_for_ajax

    sleep 1
    first('.add-imprint').click
    sleep 1
    select2 imprint_method2.name, from: "#imprint_method_select_-1"
    sleep 1
    select2 print_location2.name, from: 'Print location'
    expect(all('.editing-imprint').count).to be > 1
    sleep 1
    find('.update-imprints').click
    sleep 1.5
    expect(Imprint.where(job_id: job.id, print_location_id: print_location2.id)).to exist
    expect(order.reload.artwork_state).to eq 'no_artwork_required'
  end

  scenario 'user can add an imprint with a description', story_853: true, retry: 1 do
    visit edit_order_path(order.id, anchor: 'jobs')
    wait_for_ajax

    sleep 1
    first('.add-imprint').click
    sleep 1
    select2 imprint_method2.name, from: "#imprint_method_select_-1"
    sleep 1
    select2 print_location2.name, from: 'Print location'
    sleep 1
    find('.js-imprint-description').set 'Here ye here ye'
    expect(all('.editing-imprint').count).to be > 1
    sleep 1
    find('.update-imprints').click
    sleep 1
    expect(Imprint.where(description: 'Here ye here ye')).to exist
  end

  scenario 'user can click outside an imprint to update', what: true, story_473: true do
    visit edit_order_path(order.id, anchor: 'jobs')
    wait_for_ajax

    sleep 1
    first('.add-imprint').click
    sleep 1
    select2 imprint_method2.name, from: "#imprint_method_select_-1"
    sleep 1
    select2 print_location2.name, from: 'Print location'
    expect(all('.editing-imprint').count).to be > 1

    find('.imprints-container').click
    sleep 1
    expect(Imprint.where(job_id: job.id, print_location_id: print_location2.id)).to exist
  end

  scenario 'user can set the print location and print method of an imprint' do
    imprint
    visit edit_order_path(order.id, anchor: 'jobs')
    wait_for_ajax

    select2 imprint_method2.name, from: "#imprint_method_select_#{imprint.id}"
    sleep 1.5
    select2 print_location2.name, from: 'Print location'

    expect(all('.editing-imprint').size).to be > 1

    sleep 1.5
    find('.update-imprints').click
    wait_for_ajax

    sleep 1.5
    expect(Imprint.where(job_id: job.id, print_location_id: print_location2.id)).to exist
  end

  context 'when option types are defined for the selected imprint method' do
    let!(:imprint_method) { imprint.imprint_method }

    let!(:option_type_1) { create(:option_type, name: 'Type1', options: ['Value1', 'Value2'], imprint_method_id: imprint_method.id) }
    let!(:option_type_2) { create(:option_type, name: 'Type2', options: ['Value3', 'Value4'], imprint_method_id: imprint_method.id) }

    let(:type_1_value_1) { option_type_1.option_values[0] }
    let(:type_2_value_1) { option_type_2.option_values[0] }
    let(:type_1_value_2) { option_type_1.option_values[0] }
    let(:type_2_value_2) { option_type_2.option_values[0] }

    scenario 'user can select values from those option types' do
      visit edit_order_path(order.id, anchor: 'jobs')
      wait_for_ajax

      select2 type_1_value_2.value, from: option_type_1.name
      select2 type_2_value_2.value, from: option_type_2.name

      find('.update-imprints').click
      wait_for_ajax
      sleep 0.5

      expect(imprint.reload.option_value_ids).to eq [type_1_value_2.id, type_2_value_2.id]
    end
  end

  scenario 'user can add and edit an imprint method, and update them both' do
    imprint
    visit edit_order_path(order.id, anchor: 'jobs')
    wait_for_ajax

    sleep 1
    first('.add-imprint').click
    sleep 1.5

    within('.imprint-entry[data-id="-1"]') do
      select2 imprint_method2.name, from: "#imprint_method_select_-1"
      select2 print_location2.name, from: "#imprint_-1_print_location_id"
    end
    sleep 1.5

    within(".imprint-entry[data-id='#{job.imprints.first.id}']") do
      select2 imprint_method3.name, from: "#imprint_method_select_#{imprint.id}"
      select2 print_location3.name, from: "#imprint_#{imprint.id}_print_location_id"
    end
    sleep 1.5

    page.execute_script("$('#job-#{job.id} .update-imprints').trigger('click');")

    sleep 1.5
    expect(Imprint.where(job_id: job.id, print_location_id: print_location2.id)).to exist
    expect(Imprint.where(job_id: job.id, print_location_id: print_location3.id)).to exist
    expect(Imprint.where(job_id: job.id, print_location_id: print_location1.id)).to_not exist
  end

  scenario 'user sees error when attempting to add 2 imprints with the same location' do
    imprint
    visit edit_order_path(order.id, anchor: 'jobs')

    sleep 1
    first('.add-imprint').click
    sleep 2

    within '.imprint-entry[data-id="-1"]' do
      select2 'Digital', from: "#imprint_method_select_-1"
      sleep 2
      select2 'Front', from: "#imprint_-1_print_location_id"
    end

    sleep 2
    find('.update-imprints').click
    wait_for_ajax

    expect(page).to have_content 'already been taken'
  end

  scenario 'user can delete imprints' do
    imprint
    visit edit_order_path(order.id, anchor: 'jobs')
    wait_for_ajax

    find('.js-delete-imprint-button').click
    sleep 1.5
    expect(page).to_not have_content 'Print location'

    expect(Imprint.where(job_id: job.id)).to_not exist
  end

  context 'when the order has quotes associated with it', from_quote: true do
    given!(:quote_job) { create(:quote_job) }
    given!(:imprint) { create(:valid_imprint, job: quote_job) }
    given(:quote) { quote_job.jobbable }

    background :each do
      order.quotes << quote
    end

    scenario 'imprints can be added from those quotes', retry: 3 do
      visit edit_order_path(order.id, anchor: 'jobs')
      wait_for_ajax

      find('.imprint-from-quote').click
      wait_for_ajax

      check "imprint_id_#{imprint.id}"
      click_button 'Submit'
      wait_for_ajax

      expect(page).to have_selector ".js-print-location-select"
      expect(order.reload.imprints.map(&:print_location_id)).to eq [imprint.print_location_id]
    end

    scenario 'a user can press "Check all" to check all imprints' do
      visit edit_order_path(order.id, anchor: 'jobs')
      wait_for_ajax

      find('.imprint-from-quote').click
      wait_for_ajax

      click_button 'Check all'
      click_button 'Submit'
      wait_for_ajax

      expect(page).to have_selector ".js-print-location-select"
      expect(order.reload.imprints.map(&:print_location_id)).to eq [imprint.print_location_id]
    end
  end

  context 'name number selecting' do
    before(:each) do
      Capybara.ignore_hidden_elements = false
    end

    after(:each) do
      Capybara.ignore_hidden_elements = true
    end

    scenario 'a user can specify a name and number formats for an imprint', nn: true, name_number_spec: true, story_189: true do
      imprint
      visit edit_order_path(order.id, anchor: 'jobs')
      wait_for_ajax

      select 'Name/Number', from: 'imprint_method'

      sleep 1
      first('.name-number-checkbox').click
      evaluate_script(%<$('.js-name-number-format-fields').removeClass('hidden')>)
      sleep 1
      first('.js-name-format-field').set('Extra wide')
      first('.js-number-format-field').set('Extra long')
      first('.update-imprints').click
      wait_for_ajax

      expect(imprint.reload.name_format).to eq('Extra wide')
      expect(imprint.reload.number_format).to eq('Extra long')
    end
  end

  context 'when a name and number imprint is present', name_number: true do
    given(:imprint_two) { create(:blank_imprint, job_id: job.id, print_location_id: print_location4.id, name_number: true) }
    given!(:name_number) { create(:name_number, imprint: imprint_two) }
    given!(:line_item) { create(:imprintable_line_item) }
    given(:variant) { ImprintableVariant.find(line_item.imprintable_variant_id) }

    background(:each) do
      job.line_items = [ line_item ]
      job.imprints = [ imprint_two ]

      imprint
      visit edit_order_path(order.id, anchor: 'jobs')
      wait_for_ajax
    end

    scenario 'a user can add name/number to a previously not name/number imprint without refreshing', brkoen: true, bugfix: true do
      imprint_two.update_column :name_number, false
      visit edit_order_path(order.id, anchor: 'jobs')

      first('.name-number-checkbox').click
      evaluate_script(%<$('.js-name-number-format-fields').removeClass('hidden')>)
      sleep 1
      first('.js-name-format-field').set('Extra wide')
      first('.js-number-format-field').set('Extra long')
      first('.update-imprints').click
      wait_for_ajax

      expect(imprint_two.reload.name_format).to eq('Extra wide')
      expect(imprint_two.reload.number_format).to eq('Extra long')
    end

    scenario 'a user can add names and numbers to a table, when a name and number imprint is present', name_number_spec: true, story_190: true do
      select imprint_two.name, from: 'name_number_imprint_id'
      select variant.full_name, from: 'name_number_imprintable_variant_id'
      fill_in 'name_number_name', with: 'Test name'
      fill_in 'name_number_number', with: 'Test number'
      click_button 'Save Name number'
      wait_for_ajax

      expect(NameNumber.find_by(name: 'Test name')).to_not be_nil
      # make sure the table was updated
      expect(page).to have_css("#js-name-number-table-#{job.id} tbody tr td", text: /Test name/)

    end

    scenario 'a user sees a error when they add too many name/numbers' do
      line_item.update_column(:quantity, 0)

      select imprint_two.name, from: 'name_number_imprint_id'
      select variant.full_name, from: 'name_number_imprintable_variant_id'
      fill_in 'name_number_name', with: 'Billy'
      fill_in 'name_number_number', with: '10'
      click_button 'Save Name number'
      wait_for_ajax

      expect(NameNumber.find_by(name: 'Billy', number: '10')).to be_nil
      # make sure the table was updated
      expect(page).to_not have_css("#js-name-number-table-#{job.id} tbody tr td", text: /Billy/)

      expect(page).to have_content(/line items, trying to add/)
    end

    scenario 'a user sees a warning when there are less name/numbers than line item quantity' do
      line_item.update_column(:quantity, 10)

      visit edit_order_path(order.id, anchor: 'jobs')
      wait_for_ajax

      expect(page).to have_content "Quantities of name/numbers don't match for: #{variant.full_name}"
    end
    
    scenario 'a user can remove a name/number from the list', name_number_spec: true, story_190: true do
      expect(page).to have_css("#js-name-number-table-#{job.id} tbody tr td", text: /#{imprint_two.name}/)
      find("#destroy-name-number-#{ name_number.id }").click
      sleep 2 
      page.driver.browser.switch_to.alert.accept
      wait_for_ajax
      # TODO not sure if there is a better way of doing this
      # after deleting the item i just check that capybara can't find the td element
      # that contained its name...
      expect(page).to_not have_css("#js-name-number-table-#{job.id} tbody tr td", text: /#{imprint_two.name}/)
    end
  end

  context 'when no name/number imprint is present', story_800: true do
    scenario 'a user does not see the name/number table at all' do
      imprint
      visit edit_order_path(order.id, anchor: 'jobs')
      wait_for_ajax

      expect(page).to_not have_css "#js-name-number-table-#{job.id}"
    end

    scenario 'a user does not see the download name/number csv button' do
      imprint
      visit edit_order_path(order.id, anchor: 'jobs')
      wait_for_ajax

      expect(page).to_not have_css '.dl-name-number-csv'
    end
  end
end
