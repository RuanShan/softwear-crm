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
    visit edit_order_path(1, anchor: 'jobs')
    sleep 0.5
    expect(page).to have_content 'Test Job'
  end

  scenario 'user can edit the title in place, and it is saved in the database' do
    visit edit_order_path(1, anchor: 'jobs')
    fill_in_inline 'name', with: 'New Job Name'
    sleep 2
    expect(Job.where name: 'New Job Name').to exist
  end

  scenario 'user can edit the description in place, and it is saved in the database' do
    visit edit_order_path(1, anchor: 'jobs')
    fill_in_inline 'description', with: 'Nice new description for a lovely job'
    sleep 2
    expect(Job.where description: 'Nice new description for a lovely job').to exist
  end

  scenario 'user can create a new job, and the form immediately shows up' do
    visit edit_order_path(1, anchor: 'jobs')
    click_button 'New Job'
    sleep 0.5
    expect(all('.job-container').count).to eq 2
    expect(Job.all.count).to eq 2
  end

  scenario 'creating two jobs in a row does not fail on account of duplicate name' do
    visit edit_order_path(1, anchor: 'jobs')
    2.times { click_button 'New Job'; sleep 0.5 }
    expect(all('.job-container').count).to eq 3
    expect(Job.all.count).to eq 3
  end

  scenario 'two jobs with the same name causes error stuff to happen' do
    order.jobs << create(:job, name: 'Okay Job')
    visit edit_order_path(1, anchor: 'jobs')
    click_button 'New Job'
    sleep 0.5

    fill_in_inline 'name', with: 'Okay Job', first: true

    sleep 0.5

    expect(page).to have_content 'Name has already been taken'
  end

  scenario 'a job cannot be deleted if it has line items' do
    standard_line_item; imprintable_line_item
    visit edit_order_path(1, anchor: 'jobs')
    click_link 'Delete Job'
    sleep 0.5
    expect(page).to have_content 'Error'
    expect(job).to_not be_destroyed
  end

  scenario 'a job can be deleted' do
    visit edit_order_path(1, anchor: 'jobs')
    click_link 'Delete Job'
    sleep 0.5
    expect(order.jobs.count).to eq 0
  end

  scenario 'a job can be created and deleted without refreshing the page' do
    visit edit_order_path(1, anchor: 'jobs')
    click_button 'New Job'
    sleep 1

    order.jobs.inspect

    all('a', text: 'Delete Job').last.click
    sleep 0.5
    # find('a', text: 'Confirm').click

    order.jobs.inspect

    sleep 1
    expect(page).to have_css("#job-#{order.jobs.second.id}", :visible => false)
    expect(order.jobs.count).to eq 1
  end

  scenario 'a job can be hidden and collapsed' do
    visit edit_order_path(1, anchor: 'jobs')
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

  context 'timeline', timeline_spec: true do
    before do
      PublicActivity.enabled = true
    end
    after do
      PublicActivity.enabled = false
    end

    # Unsure why this fails on ci
    scenario 'job updates are updated on the order timeline', retry: 5, story_692: true, no_ci: true do
      PublicActivity.with_tracking do
        job.description = "New Job Description"
        job.save
      end
      sleep 0.1
      visit edit_order_path(1)
      sleep 0.1

      expect(page).to have_content "Updated job #{job.name} in order #{job.order.name}"
    end
  end
end
