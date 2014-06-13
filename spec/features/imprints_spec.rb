require 'spec_helper'
include GeneralHelpers

feature 'Imprints Management', imprint_spec: true, js: true do
  given!(:order) { create :order_with_job }
  given(:job) { order.jobs.first }
  given(:imprint) { create(:imprint, job_id: job.id, print_location_id: print_location1) }
  
  with([['Digital', 'Screen'], 
        ['Front',   'Back']]) do |name|
    2.times do |n|
      given!("imprint_method#{n+1}") { create(:valid_imprint_method, name: name[0][n]) }
      given!("print_location#{n+1}") { create(:print_location, name: name[1][n]) }
    end
  end

  scenario 'user can add a new imprint to a job' do
    visit '/orders/1/edit#jobs'
    wait_for_ajax

    first('.add-imprint').click
    wait_for_ajax

    select imprint_method2.name, from: 'Imprint Method'
    select print_location2.name, from: 'Print Location'

    click_link 'Update Line Items'

    expect(Imprint.where(job_id: job.id, print_location_id: print_location2.id)).to exist
  end

  scenario 'user can set the print location and print method of an imprint' do
    imprint
    visit '/orders/1/edit#jobs'
    wait_for_ajax

    select imprint_method1.name, from: 'Imprint Method'
    select print_location1.name, from: 'Print Location'

    find('.update-line-items').click
    wait_for_ajax

    
  end
end