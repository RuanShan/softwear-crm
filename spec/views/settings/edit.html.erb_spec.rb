require 'spec_helper'

describe 'settings/edit.html.erb', setting_spec: true do
  before(:each) do
    assign(:freshdesk_settings, {
      freshdesk_email: build_stubbed(:valid_setting, val: 'email'),
      freshdesk_url: build_stubbed(:valid_setting, val: 'url'),
      freshdesk_password: build_stubbed(:valid_setting, val: 'password')
    })
    render file: 'settings/edit'
  end

  it 'has a form to create new freshdesk settings' do
    expect(rendered).to have_selector("form[action='#{update_integrated_crms_path}']")
  end
end
