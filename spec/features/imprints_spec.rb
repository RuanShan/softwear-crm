require 'spec_helper'

feature 'Imprints Management', imprint_spec: true, js: true do
  given!(:order) { create :order_with_job }
  given(:job) { order.jobs.first }
  given(:imprint) { create(:imprint, job_id: job.id) }
  
  given(:imprint_method) { create(:valid_imprint_method_with_color_and_location) }
  5.times do |n|
    given("print_location#{n+1}") { create(:print_location) }
  end

  scenario 'user can add a new imprint to a job' do
    visit '/orders/1/edit#jobs'
    wait_for_ajax

    first('.add-imprint').click
    wait_for_ajax

    expect(page).to have_content 'Print Location'
    expect(page).to have_content 'Print Method'
  end

  scenario 'user can set the print location and print method of an imprint' do
    imprint; imprint_method
    visit '/orders/1/edit#jobs'
    wait_for_ajax

    select imprint_method.name, from: 'Imprint Method'
    select print_location1.name, from: 'Print Location'

    find('.update-line-items').click
    wait_for_ajax

    expect(Imprint.where imprint_method_id: imprint_method.id).to exist
  end
end