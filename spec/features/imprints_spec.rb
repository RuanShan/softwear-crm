require 'spec_helper'
include GeneralHelpers

feature 'Imprints Management', imprint_spec: true, js: true do
  given!(:valid_user) { create(:user) }
  background(:each) { login_as valid_user }

  given!(:order) { create :order_with_job }
  given(:job) { order.jobs.first }
  
  -> (t,&b) {b.call(t)}.call(
       [%w(Digital Screen Embroidery),
        %w(Front   Lower  Wherever)]) do |name|
    3.times do |n|
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

  scenario 'user can check the name/number box multiple times', name_number: true do
    imprint
    expect(Imprint.where(has_name_number: true)).to_not exist
    visit edit_order_path(order.id, anchor: 'jobs')
    wait_for_ajax

    first('.checkbox-container > div').click
    first('.update-imprints').click
    wait_for_ajax

    expect(Imprint.where(has_name_number: true)).to exist

    first('.checkbox-container > div').click
    first('.update-imprints').click
    wait_for_ajax

    expect(Imprint.where(has_name_number: true)).to_not exist
  end

  scenario 'user can specify a name or number for an imprint', name_number: true do
    imprint
    visit edit_order_path(order.id, anchor: 'jobs')
    wait_for_ajax

    first('.checkbox-container > div').click
    first('.js-imprint-name-number-name').set('Mike Hawk')
    first('.js-imprint-name-number-number').set(99)
    first('.js-imprint-name-number-description').set('A description of the name/number font/styles')
    first('.update-imprints').click
    wait_for_ajax

    expect(NameNumber.where(name: 'Mike Hawk', number: 99, description: 'A description of the name/number font/styles')).to exist
  end

  scenario 'A user can select a pre-populated name/number imprint method from
            the dropdown and edit name and number_format fields', story_189: true do
    imprint
    visit edit_order_path(order.id, anchor: 'jobs')
    wait_for_ajax

    expect(page).to have_css("input#name_format_#{ imprint.id }.hidden")
    expect(page).to have_css("input#number_format_#{ imprint.id }.hidden")
    find("imprint_method_#{ imprint.id }").find(:xpath, "'//select[contains(option, 'Name/Number')]'").select_option
    expect(page).to_not have_css("input#name_format_#{ imprint.id }.hidden")
    expect(page).to_not have_css("input#number_format_#{ imprint.id }.hidden")

    fill_in "#name_format_#{ imprint.id }", with: '5 inch height'
    fill_in "#number_format_#{ imprint.id }", with: 'really big'

    first('.update-imprints').click
    wait_for_ajax

    expect(Imprint.find(imprint.id).name_format).to eq '5 inch height'
    expect(Imprint.find(imprint.id).number_format).to eq 'really big'
  end

end
