require 'spec_helper'
include ApplicationHelper

feature 'Email Templates Management', js: true, email_template_spec: true, story_265: true do
  given!(:email_template) { create(:valid_email_template) }
  given!(:valid_user) { create(:alternate_user) }
  background(:each) { login_as valid_user }

  scenario 'A user can create an e-mail template' do
    visit root_path
    unhide_dashboard
    click_link 'Configuration'
    click_link 'Email Templates'
    click_link 'New Email Template'
    fill_in 'Name', with: 'A name'
    select email_template.template_type, from: 'Template type'
    fill_in 'Subject', with: 'Who cares'
    fill_in 'From', with: email_template.from
    fill_in 'To', with: email_template.to
    fill_in 'Cc', with: email_template.cc
    fill_in 'Body', with: 'Body Goes Here'
    fill_in 'Plaintext body', with: 'Body Goes Here'
    click_button 'Create Email Template'
    expect(page).to have_content("Email Template 'A name' was created successfully")
  end

end
