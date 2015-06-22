require 'spec_helper'
include ApplicationHelper
require 'email_spec'

feature 'Settings management', setting_spec: true, js: true do
  given!(:valid_user) { create(:alternate_user) }
  background(:each) { login_as(valid_user) }

  given!(:quote) { create(:valid_quote) }
  given!(:imprintable) { create(:valid_imprintable) }

  scenario 'A user can configure crm settings' do
    visit integrated_crms_path
    fill_in 'fd_settings_2_val', with: 'something_random'
    click_button 'Update'
    expect(Setting.find_by(name: 'freshdesk_email').val).to eq 'something_random'
  end
end
