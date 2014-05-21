require 'spec_helper'

feature 'Users', user_spec: true, js: true, wip: true do
	given!(:valid_user) { create(:user) }

	context 'with valid credentials' do
		scenario 'I can log in' do
			login_through_form_as(valid_user).with('1234567890') do
				expect(page).to have_content 'success'
			end
			expect(current_path).to eq '/'
		end
	end
end