require 'spec_helper'

describe 'email_templates/index.html.erb', email_template_spec: true, story_265: true do

  before(:each) do
    assign(:email_templates, [build_stubbed(:valid_email_template)])
    render
  end

  it 'has a table of email templates' do
    expect(rendered).to have_selector('table#email_templates_list')
  end
end