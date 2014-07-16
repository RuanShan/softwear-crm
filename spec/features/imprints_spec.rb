require 'spec_helper'
include GeneralHelpers

feature 'Imprints Management', imprint_spec: true, js: true, imprint_features: true do
  given!(:valid_user) { create(:user) }
  before(:each) do
    login_as valid_user
  end

  given!(:order) { create :order_with_job }
  given(:job) { order.jobs.first }
  
  -> (t,&b){b.call(t)}.call(
       [['Digital', 'Screen', 'Embroidery'], 
        ['Front',   'Lower',  'Wherever']]) do |name|
    3.times do |n|
      let!("imprint_method#{n+1}") { create(:valid_imprint_method, 
                                               name: name[0][n]) }
      let!("print_location#{n+1}") { create(:print_location, name: name[1][n], 
                                               imprint_method_id: send("imprint_method#{n+1}").id) }
    end
  end

  given(:imprint) { create(:imprint, job_id: job.id, print_location_id: print_location1.id) }

  scenario 'user can add a new imprint to a job' do
    visit edit_order_path(order.id, anchor: 'jobs')
    wait_for_ajax

    first('.add-imprint').click
    sleep 1
    select imprint_method2.name, from: 'Imprint method'
    sleep 1.5
    select print_location2.name, from: 'Print location'
    expect(all('.editing-imprint').count).to be > 1
    find('.update-imprints').click
    expect(Imprint.where(job_id: job.id, print_location_id: print_location2.id)).to exist
  end

  scenario 'user can set the print location and print method of an imprint' do
    imprint
    visit edit_order_path(order.id, anchor: 'jobs')
    wait_for_ajax

    select imprint_method2.name, from: 'Imprint method'
    sleep 1.5
    select print_location2.name, from: 'Print location'

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
      select imprint_method2.name, from: 'Imprint method'
      select print_location2.name, from: 'Print location'
    end
    sleep 1.5

    within(".imprint-entry[data-id='#{job.imprints.first.id}']") do
      select imprint_method3.name, from: 'Imprint method'
      select print_location3.name, from: 'Print location'
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

  scenario 'user can delete imprints' do
    imprint
    visit edit_order_path(order.id, anchor: 'jobs')
    wait_for_ajax

    find('span[onclick*="deleteImprint"]').click
    sleep 1.5
    expect(page).to_not have_content 'Print location'

    expect(Imprint.where(job_id: job.id)).to_not exist
  end

end
private