require 'spec_helper'
include ApplicationHelper

feature 'Email Templates Management', js: true, email_template_spec: true, story_265: true, new: true do
  given!(:email_template) { create(:valid_email_template) }
  given!(:valid_user) { create(:alternate_user) }
  background(:each) { login_as valid_user }

  scenario 'A user can view a list of email templates' do
    visit root_path
    unhide_dashboard
    click_link 'Configuration'
    click_link 'Email Templates'
    expect(page).to have_css('tbody')
    expect(page).to have_content('View and edit email templates')
  end

  scenario 'A user can create an email template' do
    visit email_templates_path
    click_link 'Add an Email Template'
    fill_in 'Subject', with: 'Your new quote from Ann Arbor Tees'
    fill_in 'Body', with: 'Thank you {{quote.name}} for your purchase'
    click_button 'Create Email Template'
    expect(EmailTemplate.where(subject: 'Your new quote from Ann Arbor Tees')).to exist
  end

  scenario 'A user can edit an email template' do
    visit email_templates_path
    find("a[href='/configuration/email_templates/#{email_template.id}/edit']").click
    fill_in 'Subject', with: 'New template lololol'
    click_button 'Update Email Template'
    expect(EmailTemplate.where(subject: 'New template lololol')).to exist
  end

  scenario 'A user can delete an email template' do
    visit email_templates_path
    find("a[href='/configuration/email_templates/#{email_template.id}']").click
    page.driver.browser.switch_to.alert.accept
    wait_for_ajax
    expect(EmailTemplate.where(subject: email_template.subject).blank?).to be_truthy
  end

  scenario 'A user can email a template to a customer', pending: 'Fill this mother in' do
    expect(false).to be_truthy
  end
end