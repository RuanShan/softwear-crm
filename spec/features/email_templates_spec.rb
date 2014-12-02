require 'spec_helper'
include ApplicationHelper

feature 'Email Templates Management', js: true, email_template_spec: true, story_265: true do
  given!(:email_template) { create(:valid_email_template) }
  given!(:valid_user) { create(:alternate_user) }
  background(:each) { login_as valid_user }

  scenario 'A user can view a list of email templates' do
    visit root_path
    unhide_dashboard
    click_link 'Configuration'
    click_link 'Email Templates'
    expect(page).to have_css('tbody')
  end

  scenario 'A user can create an email template' do
    visit email_templates_path
    click_link 'New Email Template'
    fill_in 'Template', with: 'New template!!'
    click_button 'Create Template'
    expect(EmailTemplate.where(template: 'New template!!')).to exist
  end

  scenario 'A user can edit an email template' do
    visit email_templates_path
    find("a[href='/configuration/email_templates/#{email_template.id}/edit']").click
    fill_in 'Template', with: 'New template lololol'
    click_button 'Update Template'
    expect(EmailTemplate.where(template: 'New template lololol')).to exist
  end

  scenario 'A user can delete an email template' do
    visit email_templates_path
    find("a[href='configuration/email_templates/#{email_template.id}']").click
    page.driver.browser.switch_to.alert.accept
    expect(EmailTemplate.where(template: email_template.template)).to_not exist
  end

  scenario 'A user can email a template to a customer' do
  #   TODO: fill this mother in
  end
end