require 'spec_helper'

describe 'email_templates/edit.html.erb', email_template_spec: true, story_265: true do
  let(:email_template) { build_stubbed(:valid_email_template) }

  before(:each) do
    assign(:email_template, email_template)
    render file: 'email_templates/edit', id: email_template.to_param
  end

  it 'has a form to create a new template' do
    expect(rendered).to have_selector("form[action='#{email_template_path(email_template)}'][method='post']")
  end
end
