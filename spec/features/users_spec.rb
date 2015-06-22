require 'spec_helper'

feature 'Users', user_spec: true, js: true do
  given!(:valid_user) { create(:user) }

  context 'with valid credentials', story_692: true do
    scenario 'I can log in' do
      login_through_form_as(valid_user).with('1234567890') do
        expect(page).to have_content 'success'
      end
      expect(current_path).to eq '/'
    end
  end

  context 'logged in' do
    before(:each) { login_as valid_user }

    scenario 'I see my name on the dashboard' do
      visit root_path
      unhide_dashboard
      expect(page).to have_content "Welcome, #{valid_user.first_name} #{valid_user.last_name[0,1]}."
    end

    scenario 'I can view a list of users' do
      visit users_path
      expect(page).to have_css "tr#user_#{valid_user.id} > td", text: valid_user.full_name
    end

    scenario "I can edit a user's info" do
      visit users_path
      first('a[title=Edit]').click
      fill_in 'Last name', with: 'Newlast_name'
      click_button 'Update'
      wait_for_ajax
      expect(page).to have_content 'success'
      expect(User.where(last_name: 'Newlast_name')).to exist
    end

    scenario 'I can create a new user account' do
      visit users_path
      click_link 'Create new user'
      fill_in 'Email', with: 'newguy@example.com'
      fill_in 'First name', with: 'New'
      fill_in 'Last name', with: 'Last'
      select valid_user.store.name, from: 'Store'
      click_button 'Create'
      expect(page).to have_content 'success'
    end

    scenario 'I can change my password' do
      visit edit_user_path(valid_user)
      click_link 'Change password'
      fill_in 'Password',              with: 'NewPassword'
      fill_in 'Password confirmation', with: 'NewPassword'
      fill_in 'Current password',      with: '1234567890'
      click_button 'Update'
      expect(page).to have_content 'success'
    end

    scenario 'I can update my freshdesk information' do
      visit edit_user_path valid_user
      fill_in 'Freshdesk Password', with: 'pw4freshdesk'
      fill_in 'Freshdesk Email', with: 'capybara@annarbortees.com'
      click_button 'Update'
      expect(page).to have_content 'success'
    end

    scenario 'I can update my insightly api key', story_511: true do
      visit edit_user_path valid_user
      fill_in 'Insightly Api Key', with: 'aaaaaaaaaaaaaaah'
      click_button 'Update'
      expect(page).to have_content 'success'
      expect(valid_user.reload.insightly_api_key).to eq 'aaaaaaaaaaaaaaah'
    end

    # Currently cannot figure out how to interact with the dashboard or header
    # headlessly (for some reason)
    scenario 'I can lock myself', no_ci: true do
      visit orders_path
      find('a#account-menu').click
      sleep 0.2
      click_link 'Lock me'
      sleep 0.2
      expect(current_path).to eq '/users/sign_in'
    end

    scenario 'I am locked out if I idle for too long' do
      visit orders_path
      wait_for_ajax
      execute_script 'idleTimeoutMs = 1000; idleWarningSec = 5;'
      sleep 0.1
      find('th', text: 'Salesperson').click
      sleep 1.5
      expect(page).to have_css '.modal-body'
      sleep 6
      expect(current_path).to eq new_user_session_path
    end

    scenario 'If I see the lock-out warning, I can cancel it by clicking' do
      visit orders_path
      wait_for_ajax
      execute_script 'idleTimeoutMs = 1000; idleWarningSec = 5;'
      sleep 0.1
      find('th', text: 'Salesperson').click
      sleep 1.3
      find('.modal-title').click
      wait_for_ajax
      expect(page).to_not have_css '.modal-body'
    end

    scenario 'I can log out' do
      visit root_path
      unhide_dashboard
      sleep 0.5
      first('a', text: 'Logout').click
      expect(current_path).to eq '/users/sign_in'
    end
  end
end
