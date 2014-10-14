require 'spec_helper'
include GeneralHelpers

feature 'Imprints Management', imprint_spec: true, js: true do
  given!(:valid_user) { create(:user) }
  background(:each) { login_as valid_user }

  given!(:order) { create :order_with_job }
  given(:job) { order.jobs.first }
  
  -> (t,&b) {b.call(t)}.call(
       [%w(Digital Screen Embroidery Name/Number),
        %w(Front   Lower  Wherever Somewhere)]) do |name|
    4.times do |n|
      let!("imprint_method#{n+1}") { create(:valid_imprint_method, 
                          name: name.first[n]) }
      let!("print_location#{n+1}") { create(:valid_print_location, name: name[1][n],
                          imprint_method_id: send("imprint_method#{n+1}").id) }
    end
  end

  given(:imprint) { create(:blank_imprint, job_id: job.id, print_location_id: print_location1.id) }

  scenario 'user can add a new imprint to a job', retry: 1, busted: true do
    visit edit_order_path(order.id, anchor: 'jobs')
    wait_for_ajax

    first('.add-imprint').click
    sleep 0.5
    find('.js-imprint-method-select').select imprint_method2.name
    sleep 0.5
    find('.js-print-location-select').select print_location2.name
    expect(all('.editing-imprint').count).to be > 1
    sleep 0.5
    find('.update-imprints').click
    sleep 0.5
    expect(Imprint.where(job_id: job.id, print_location_id: print_location2.id)).to exist
  end

  scenario 'user can set the print location and print method of an imprint' do
    imprint
    visit edit_order_path(order.id, anchor: 'jobs')
    wait_for_ajax

    find('.js-imprint-method-select').select imprint_method2.name
    sleep 1.5
    find('.js-print-location-select').select print_location2.name

    expect(all('.editing-imprint').count).to be > 1

    sleep 1.5
    find('.update-imprints').click
    wait_for_ajax

    sleep 1.5
    expect(Imprint.where(job_id: job.id, print_location_id: print_location2.id)).to exist
  end

  scenario 'user can add and edit an imprint method, and update them both',
     pending: 'WEIRD: This tests neither passes nor fails, unless we randomly click/scroll/resize during the
              test, also unknown timeline update error on capybara click that isnt seen when user
              clicks during test' do

    imprint
    visit edit_order_path(order.id, anchor: 'jobs')
    wait_for_ajax

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

    # page.execute_script("$('#job-#{job.id} .update-imprints').trigger('click');")
    # This is the line that causes things to get weird

    expect(Imprint.where(job_id: job.id, print_location_id: print_location2.id)).to exist
    expect(Imprint.where(job_id: job.id, print_location_id: print_location3.id)).to exist
    expect(Imprint.where(job_id: job.id, print_location_id: print_location1.id)).to_not exist
  end

  scenario 'user sees error when attempting to add 2 imprints with the same location' do
    imprint
    visit edit_order_path(order.id, anchor: 'jobs')
    wait_for_ajax

    first('.add-imprint').click
    wait_for_ajax

    find('.update-imprints').click
    wait_for_ajax

    expect(page).to have_content 'already been taken'
  end

  scenario 'user can delete imprints', wtf: true do
    imprint
    visit edit_order_path(order.id, anchor: 'jobs')
    wait_for_ajax

    find('.js-delete-imprint-button').click
    sleep 1.5
    expect(page).to_not have_content 'Print location'

    expect(Imprint.where(job_id: job.id)).to_not exist
  end

  scenario 'user can check the name/number box multiple times', name_number: true, pending: 'might not need this checkbox' do
    imprint
    expect(Imprint.where(has_name_number: true)).to_not exist
    visit edit_order_path(order.id, anchor: 'jobs')
    wait_for_ajax

    first('.update-imprints').click
    wait_for_ajax

    expect(Imprint.where(has_name_number: true)).to exist

    first('.checkbox-container > div').click
    first('.update-imprints').click
    wait_for_ajax

    expect(Imprint.where(has_name_number: true)).to_not exist
  end

  scenario 'a user can specify a name and number formats for an imprint', name_number: true, story_189: true do
    imprint
    visit edit_order_path(order.id, anchor: 'jobs')
    wait_for_ajax

    select 'Name/Number', from: 'imprint_method'

    first('.js-name-format-field').set('Extra wide')
    first('.js-number-format-field').set('Extra long')
    first('.update-imprints').click
    wait_for_ajax

    expect(imprint.reload.name_format).to eq('Extra wide')
    expect(imprint.reload.number_format).to eq('Extra long')
  end

  scenario 'a user can add names and numbers to a table, when a name and number imprint is present', name_number: true, story_190: true do
    imprint
    visit edit_order_path(order.id, anchor: 'jobs')
    wait_for_ajax

    select 'Name/Number', from: 'imprint_method'

    # select imprintable_variant from variant select field
    fill_in :name, with: 'Test name'
    fill_in :number, with: 'Test number'
    click_link 'Add'

    expect(NameNumber.find_by(name: 'Test name')).to exist
    expect(page).to have_selector('relevant-table-row-selector')
  end
end
