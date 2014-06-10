require 'spec_helper'

feature 'Jobs management', js: true, job_spec: true do
	given!(:order) { create(:order_with_job) }
	given(:job) { order.jobs.first }

	given!(:valid_user) { create(:user) }
	before(:each) do
    login_as valid_user
  end

  scenario 'user visits /orders/1/edit#jobs and is switched to the jobs tab' do
  	visit '/orders/1/edit#jobs'
  	sleep 0.5
  	expect(page).to have_content 'Test Job'
  end

  scenario 'user can edit the title in place, and it is saved in the database' do
  	visit '/orders/1/edit#jobs'
  	fill_in_inline 'name', with: 'New Job Name'
  	sleep 2
  	expect(Job.where name: 'New Job Name').to exist
  end

  scenario 'user can edit the description in place, and it is saved in the database' do
  	visit '/orders/1/edit#jobs'
  	fill_in_inline 'description', with: 'Nice new description for a lovely job'
  	sleep 2
  	expect(Job.where description: 'Nice new description for a lovely job').to exist
  end

  scenario 'user can create a new job, and the form immediately shows up' do
  	visit '/orders/1/edit#jobs'
  	click_button 'New Job'
  	sleep 0.5
  	expect(all('form[id*="job"]').count).to eq 2
  	expect(Job.all.count).to eq 2
  end

  scenario 'creating two jobs in a row does not fail on account of duplicate name' do
  	visit '/orders/1/edit#jobs'
  	2.times { click_button 'New Job'; sleep 0.5 }
  	expect(all('form[id*="job"').count).to eq 3
  	expect(Job.all.count).to eq 3
  end

  scenario 'two jobs with the same name causes error stuff to happen' do
    order.jobs << create(:job, name: 'Okay Job')
    visit '/orders/1/edit#jobs'
    click_button 'New Job'
    sleep 0.5

    within_form_for job do
      fill_in_inline 'name', with: 'Okay Job'
    end
    sleep 0.5

    expect(page).to have_content 'Name has already been taken'
  end

  scenario 'a job can be deleted' do
    visit '/orders/1/edit#jobs'
    click_button 'Delete Job'
    sleep 0.5
    expect(order.jobs.count).to eq 0
  end

  scenario 'a job can be created and deleted without refreshing the page' do
    visit '/orders/1/edit#jobs'
    click_button 'New Job'
    sleep 0.5
    all('button', text: 'Delete Job').last.click
    sleep 0.5
    expect(order.jobs.count).to eq 1
  end
end