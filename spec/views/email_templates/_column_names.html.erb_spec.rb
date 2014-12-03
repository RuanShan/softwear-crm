require 'spec_helper'

describe 'email_templates/_column_names.html.erb', email_template_spec: true, story_265: true do
  before(:each) { render 'email_templates/column_names', column_names: %w(id salesperson_id first_name last_name) }

  it 'displays a header with instructions on what the available methods are' do
    expect(rendered).to have_content('Here are the available methods you have to use:')
  end

  it 'displays an unordered list with all the column_names' do
    expect(rendered).to have_css('ul li', text: 'id')
    expect(rendered).to have_css('ul li', text: 'salesperson_id')
    expect(rendered).to have_css('ul li', text: 'first_name')
    expect(rendered).to have_css('ul li', text: 'last_name')
  end
end