require 'spec_helper'

feature 'Users', user_spec: true, js: true, wip: true do
	given!(:valid_user) { create(:user) }

	context 'with valid credentials' do
		scenario 'I can log in' do
			login_through_form_as(valid_user).with('1234567890') do
				expect(page).to have_css '*', text: 'success'
			end
			expect(current_path).to eq '/'
		end
	end

	context 'logged in' do
	  before(:each) do
	    login_as valid_user
	  end

	  scenario 'I can view a list of users' do
	  	visit root_path
	  	unhide_dashboard
	  	click_link 'Administration'
	  	wait_for_ajax
	  	click_link 'Users'
	  	wait_for_ajax
	  	expect(page).to have_css '*', text: valid_user.full_name
	  end

	  scenario "I can edit a user's info" do
	  	visit users_path
	  	first('a[title=Edit]').click
	  	fill_in 'Last name', with: 'NewLastname'
	  	click_button 'Submit'
	  	wait_for_ajax
	  	expect(page).to have_css '*', text: 'success'
	  	expect(User.where(lastname: 'NewLastname')).to exist
	  end
	end
end