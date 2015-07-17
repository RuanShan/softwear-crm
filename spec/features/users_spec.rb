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

    context 'I see my current store on the dashboard', story_708: true do
      let!(:store_1) { create(:valid_store, name: 'Store One') }
      let!(:store_2) { create(:valid_store, name: 'Store Two') }

      background do
        valid_user.store = store_1
        valid_user.save!
      end

      scenario 'and change it' do
        visit root_path
        unhide_dashboard

        expect(page).to have_content 'My Store'
        expect(page).to have_content 'Store One'
        find('span[data-placeholder=Store]').click
        find('.editable-input > select').select store_2.name
        find('.editable-submit').click

        sleep 1

        expect(page).to have_content 'Store Two'
        expect(page).to_not have_content 'Store One'
      end
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

    # Of course, these don't work on the CI...
    context 'Profile pictures', no_ci: true do
      scenario 'I can add a profile picture to be displayed instead of Tom Cruise', story_689: true do
        visit edit_user_path(valid_user)
        sleep 2
        find('#user_profile_picture_attributes_file', visible: false).set("#{Rails.root}/spec/fixtures/images/macho.jpg")
        click_button 'Update'

        visit root_path
        unhide_dashboard
        expect(page).to have_css("img[src='#{valid_user.reload.profile_picture.file.url(:medium)}']")
      end

      scenario 'I can add a profile picture, then edit other fields without losing the image', story_689: true do
        visit edit_user_path(valid_user)
        find('#user_profile_picture_attributes_file', visible: false).set("#{Rails.root}/spec/fixtures/images/macho.jpg")
        click_button 'Update'

        visit edit_user_path(valid_user)
        click_button 'Update'

        visit root_path
        unhide_dashboard
        expect(page).to have_css("img[src='#{valid_user.reload.profile_picture.file.url(:medium)}']")
      end

      scenario 'I can upload a signature', story_690: true do
        visit edit_user_path(valid_user)
        sleep 2
        find('#user_signature_attributes_file', visible: false).set("#{Rails.root}/spec/fixtures/images/macho.jpg")
        click_button 'Update'

        expect(valid_user.reload.signature).to_not be_nil
      end

      scenario 'When I have a signature, I can see it on the edit page', story_690: true do
        visit edit_user_path(valid_user)
        sleep 2
        find('#user_signature_attributes_file', visible: false).set("#{Rails.root}/spec/fixtures/images/macho.jpg")
        click_button 'Update'

        visit edit_user_path(valid_user)
        expect(page).to have_css("img[src='#{valid_user.reload.signature.file.url(:signature)}']")
      end
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
