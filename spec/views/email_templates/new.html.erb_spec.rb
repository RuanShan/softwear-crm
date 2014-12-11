require 'spec_helper'

describe 'email_templates/new.html.erb', email_template_spec: true, story_265: true do
  before(:each) do
    assign(:email_template, EmailTemplate.new)
    render
  end

  it 'has a form to create a new email template' do
    expect(rendered).to have_selector("form[action='#{email_templates_path}'][method='post']")
  end
end
