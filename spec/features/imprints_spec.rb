require 'spec_helper'
include GeneralHelpers

feature 'Imprints Management', imprint_spec: true, js: true do
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

  scenario 'user can add a new imprint to a job', retry: 1 do
    visit edit_order_path(order.id, anchor: 'jobs')
    wait_for_ajax

    sleep 1
    first('.add-imprint').click
    sleep 1
    find('.js-imprint-method-select').select imprint_method2.name
    sleep 1
    find('.js-print-location-select').select print_location2.name
    expect(all('.editing-imprint').count).to be > 1
    sleep 1
    find('.update-imprints').click
    sleep 1
    expect(Imprint.where(job_id: job.id, print_location_id: print_location2.id)).to exist
  end

  scenario 'user can add an imprint with a description', story_853: true, retry: 1 do
    visit edit_order_path(order.id, anchor: 'jobs')
    wait_for_ajax

    sleep 1
    first('.add-imprint').click
    sleep 1
    find('.js-imprint-method-select').select imprint_method2.name
    sleep 1
    find('.js-print-location-select').select print_location2.name
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
    find('.js-imprint-method-select').select imprint_method2.name
    sleep 1
    find('.js-print-location-select').select print_location2.name
    expect(all('.editing-imprint').count).to be > 1

    find('.imprints-container').click
    sleep 1
    expect(Imprint.where(job_id: job.id, print_location_id: print_location2.id)).to exist
  end

  scenario 'user can set the print location and print method of an imprint' do
    imprint
    visit edit_order_path(order.id, anchor: 'jobs')
    wait_for_ajax

    find('.js-imprint-method-select').select imprint_method2.name
    sleep 1.5
    find('.js-print-location-select').select print_location2.name

    expect(all('.editing-imprint').size).to be > 1

    sleep 1.5
    find('.update-imprints').click
    wait_for_ajax

    sleep 1.5
    expect(Imprint.where(job_id: job.id, print_location_id: print_location2.id)).to exist
  end

  scenario 'user can add and edit an imprint method, and update them both' do
    imprint
    visit edit_order_path(order.id, anchor: 'jobs')
    wait_for_ajax

    sleep 1
    first('.add-imprint').click
    sleep 1.5

    within('.imprint-entry[data-id="-1"]') do
      find('.js-imprint-method-select').select imprint_method2.name
      find('.js-print-location-select').select print_location2.name
    end
    sleep 1.5

    within(".imprint-entry[data-id='#{job.imprints.first.id}']") do
      find('.js-imprint-method-select').select imprint_method3.name
      find('.js-print-location-select').select print_location3.name
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
      find('.js-imprint-method-select').select 'Digital'
      sleep 2
      find('.js-print-location-select').select 'Front'
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

  context 'when a name and number imprint is present' do
    given(:imprint_two) { create(:blank_imprint, job_id: job.id, print_location_id: print_location4.id, name_number: true) }
    given!(:name_number) { create(:name_number, imprint: imprint_two) }
    given!(:line_item) { create(:imprintable_line_item) }

    background(:each) do
      job.line_items = [ line_item ]
      job.imprints = [ imprint_two ]

      imprint
      visit edit_order_path(order.id, anchor: 'jobs')
      wait_for_ajax
    end

    scenario 'a user can add name/number to a previously not name/number imprint without refreshing', bugfix: true do
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
      # select imprintable_variant from variant select field
      select imprint_two.name, from: 'name_number_imprint_id'
      select ImprintableVariant.find(line_item.imprintable_variant_id).full_name, from: 'name_number_imprintable_variant_id'
      fill_in 'name_number_name', with: 'Test name'
      fill_in 'name_number_number', with: 'Test number'
      click_button 'Save Name number'
      wait_for_ajax

      expect(NameNumber.find_by(name: 'Test name')).to_not be_nil
      # make sure the table was updated
      expect(page).to have_css("#js-name-number-table-#{job.id} tbody tr td", text: /Test name/)

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
