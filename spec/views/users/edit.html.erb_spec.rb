require 'spec_helper'

describe 'users/edit.html.erb', user_spec: true do
	let!(:user) { create(:user) }
	before(:each) do
		assign(:user, user)
	end

  context 'when the user views their own profile' do
    before(:each) do
      assign(:current_user, user)
    end

    it "displays the user's authentication token", story_192: true do
      render
      expect(rendered)
        .to have_content "( Authentication token: #{user.authentication_token} )"
    end
  end

  context "when the user views another user's profile" do
    let!(:other_user) { create(:alternate_user) }

    before(:each) do
      assign(:current_user, other_user)
    end

    it 'does not display an authentication token' do
      render
      expect(rendered).to_not have_content other_user.authentication_token
    end
  end

	it 'has fields for first_name, last_name and email' do
		render
		within_form_for User do
			expect(rendered).to have_field_for :first_name
			expect(rendered).to have_field_for :last_name
			expect(rendered).to have_field_for :email
      expect(rendered).to have_field_for :store_id
		end
  end

  it 'has fields to configure freshdesk information' do
    render
    within_form_for User do
      expect(rendered).to have_field_for :freshdesk_password
      expect(rendered).to have_field_for :freshdesk_email
    end
  end

	it 'has submit button' do
		render
		expect(rendered).to have_selector 'input[type="submit"]'
	end

	it 'shows change password button if the user is viewing their own edit page' do
		assign(:current_user, user)
		render
		expect(rendered).to have_button_or_link_to change_password_path
	end

	it "does not show change password button if user is viewing someone else's page" do
		assign(:current_user, create(:alternate_user))
		render
		expect(rendered).to_not have_button_or_link_to change_password_path
	end

end