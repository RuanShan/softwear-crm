require 'spec_helper'

describe 'email_templates/index.html.erb', email_template_spec: true, story_265: true do

  let(:email_template) { build_stubbed(:valid_email_template) }
  before(:each) do
    assign(:email_templates, [build_stubbed(:valid_email_template)])
    render
  end


  it 'has a table of email templates, displays name, template type, subject' do
    expect(rendered).to have_selector('table#email_templates_list')
    expect(rendered).to have_selector('th', text: 'Name')
    expect(rendered).to have_selector('td', text: email_template.name)
    expect(rendered).to have_selector('th', text: 'Template Type')
    expect(rendered).to have_selector('td', text: email_template.template_type)
    expect(rendered).to have_selector('dt', text: 'Subject')
    expect(rendered).to have_selector('dd', text: email_template.subject)
    expect(rendered).to have_selector('dt', text: 'From')
    expect(rendered).to have_selector('dd', text: email_template.from)
  end

  it 'has a link to add an e-mail template' do
    expect(rendered).to have_link('New Email Template', href: new_email_template_path)
  end


end
