require 'spec_helper'
include ApplicationHelper

feature 'Email Templates Management', js: true, email_template_spec: true, story_265: true do
  given!(:email_template) { create(:valid_email_template) }
  given!(:valid_user) { create(:alternate_user) }
  background(:each) { login_as valid_user }

  scenario 'A user can create an e-mail template, where the body is a summernote input' do
    visit root_path
    unhide_dashboard
    click_link 'Configuration'
    click_link 'Email Templates'
    click_link 'New Email Template'
    fill_in 'Name', with: email_template.name
    select email_template.template_type, from: 'Template type'
    fill_in 'Subject', with: email_template.subject
    fill_in 'From', with: email_template.from
    fill_in 'Cc', with: email_template.cc
    fill_in_summernote('#email_template_body', with: 'Body Goes Here')
    click_button 'Create Email Template'
    expect(page).to have_content("Email Template '#{email_template.name}' was created successfully")
  end

end