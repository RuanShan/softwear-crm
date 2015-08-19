require 'spec_helper'

describe 'settings/_form.html.erb', setting_spec: true do
  before(:each) do
    freshdesk_settings = {
        freshdesk_email: build_stubbed(:valid_setting, val: 'email'),
        freshdesk_url: build_stubbed(:valid_setting, val: 'url'),
        freshdesk_password: build_stubbed(:valid_setting, val: 'password')
    }
    render 'form', freshdesk_settings: freshdesk_settings, insightly_settings: nil, production_crm_settings: nil 
  end

  it 'has a form with appropriate fields' do
    expect(rendered).to have_css 'input[value="email"]'
    expect(rendered).to have_css 'input[value="url"]'
    expect(rendered).to have_css 'input[value="password"]'
  end
end
