require 'spec_helper'

describe 'email_templates/_table.html.erb', email_template_spec: true, story_265: true do

  let!(:email_templates) { [build_stubbed(:valid_email_template)] }
  before(:each) { render 'email_templates/table', email_templates: email_templates }

  it 'has a table with headers for to, cc, bcc, subject and body' do
    expect(rendered).to have_selector('th', text: 'Subject')
    expect(rendered).to have_selector('th', text: 'From')
    expect(rendered).to have_selector('th', text: 'Cc')
    expect(rendered).to have_selector('th', text: 'Bcc')
    expect(rendered).to have_selector('th', text: 'Body')
  end

  it 'has a table with the email template\'s to, cc, bcc, subject and body fields' do
    expect(rendered).to have_selector('td', text: email_templates.first.subject)
    expect(rendered).to have_selector('td', text: email_templates.first.from)
    expect(rendered).to have_selector('td', text: email_templates.first.cc)
    expect(rendered).to have_selector('td', text: email_templates.first.bcc)
    expect(rendered).to have_selector('td', text: email_templates.first.body)
  end

  it 'has a button to destroy and edit the email template' do
    expect(rendered).to have_selector("tr#email_template_#{email_templates.first.id} td a[href='#{email_template_path(email_templates.first)}']")
    expect(rendered).to have_selector("tr#email_template_#{email_templates.first.id} td a[href='#{edit_email_template_path(email_templates.first)}']")
  end
end
