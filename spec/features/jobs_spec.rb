require 'spec_helper'

feature 'Jobs management', js: true, job_spec: true do
  given!(:order) { create(:order_with_job) }
  given(:job) { order.jobs.first }

  given!(:valid_user) { create(:user) }
  before(:each) do
    login_as valid_user
  end

  given(:standard_line_item) { create(:non_imprintable_line_item, line_itemable_id: job.id, line_itemable_type: 'Job') }
  given(:imprintable_line_item) { create(:imprintable_line_item, line_itemable_id: job.id, line_itemable_type: 'Job') }

  scenario 'user visits /orders/1/edit#jobs and is switched to the jobs tab' do
    visit edit_order_path(order, anchor: 'jobs')
    sleep 0.5
    expect(page).to have_content 'Test Job'
  end

  scenario 'user can edit the title in place, and it is saved in the database' do
    visit edit_order_path(order, anchor: 'jobs')
    set_editable 'name', 'New Job Name'
    sleep 2
    expect(Job.where name: 'New Job Name').to exist
  end

  scenario 'user can edit the description in place, and it is saved in the database' do
    visit edit_order_path(order, anchor: 'jobs')
    set_editable 'description', 'Nice new description for a lovely job'
    sleep 2
    expect(Job.where description: 'Nice new description for a lovely job').to exist
  end

  scenario 'a job can be duplicated', story_959: true do
    visit edit_order_path(order, anchor: 'jobs')

    find('.dup-job-button').click

    expect(page).to have_content "#{job.name} 2"
    expect(Job.where(name: "#{job.name} 2")).to exist
  end

  scenario 'user can create a new job, and the form immediately shows up' do
    visit edit_order_path(order, anchor: 'jobs')
    click_button 'New Job'
    sleep 0.5
    expect(all('.job-container').count).to eq 2
    expect(Job.all.count).to eq 2
  end

  scenario 'creating two jobs in a row does not fail on account of duplicate name' do
    visit edit_order_path(order, anchor: 'jobs')
    2.times { click_button 'New Job'; sleep 1.5 }
    expect(all('.job-container').count).to eq 3
    expect(Job.all.count).to eq 3
  end

  scenario 'a job cannot be deleted if it has line items' do
    standard_line_item; imprintable_line_item
    visit edit_order_path(order, anchor: 'jobs')
    click_link 'Delete Job'
    sleep 0.5
    expect(page).to have_content 'Error'
    expect(job).to_not be_destroyed
  end

  scenario 'a job can be deleted' do
    visit edit_order_path(order, anchor: 'jobs')
    click_link 'Delete Job'
    sleep 0.5
    expect(order.jobs.count).to eq 0
  end

  scenario 'a job can be created and deleted without refreshing the page' do
    last_job = order.jobs.last
    visit edit_order_path(order, anchor: 'jobs')
    click_button 'New Job'
    sleep 1

    order.jobs.inspect

    all('a', text: 'Delete Job').last.click
    wait_for_ajax

    expect(page).to have_css("#job-#{last_job.id}", :visible => false)
    expect(order.jobs.reload.count).to eq 1
  end

  scenario 'a job can be hidden and collapsed' do
    visit edit_order_path(order, anchor: 'jobs')
    expect(page).to have_content job.name
    expect(page).to have_content job.description

    find('.collapse-job-btn').click
    sleep 0.5

    expect(page).to have_content job.name
    expect(page).to_not have_content job.description

    find('.collapse-job-btn').click
    sleep 0.5

    expect(page).to have_content job.name
    expect(page).to have_content job.description
  end
end
