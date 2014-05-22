require 'spec_helper'

feature 'Users', user_spec: true, js: true do
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

	  scenario 'I see my name on the dashboard' do
	  	visit root_path
	  	unhide_dashboard
	  	expect(page).to have_css '*', text: "Welcome back, #{valid_user.full_name}"
	  end

	  scenario 'I can view a list of users' do
	  	visit root_path
	  	unhide_dashboard
	  	click_link 'Administration'
	  	wait_for_ajax
	  	click_link 'Users'
	  	wait_for_ajax
	  	expect(page).to have_css "tr#user_#{valid_user.id} > td", text: valid_user.full_name
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

	  scenario "I can create a new user account" do
	  	visit users_path
	  	click_link 'Create new user'
	  	fill_in 'Email', with: 'newguy@example.com'
	  	fill_in 'First name', with: 'New'
	  	fill_in 'Last name', with: 'Last'
	  	click_button 'Create'
	  	page.driver.browser.switch_to.alert.accept
	  	expect(page).to have_css '*', text: 'success'
	  end

	  scenario "I can change my password", wip: true, donow: true do
	  	visit edit_user_path(valid_user)
	  	click_link 'Change password'
	  	fill_in 'Password',              with: 'NewPassword'
	  	fill_in 'Password confirmation', with: 'NewPassword'
	  	fill_in 'Current password',      with: '1234567890'
	  	click_button 'Update'
	  	expect(page).to have_css '*', text: 'success'
	  end

	  scenario 'I can log out' do
	  	visit root_path
	  	unhide_dashboard
	  	first('a', text: 'Logout').click
	  	expect(current_path).to eq '/users/sign_in'
	  end
	end
end