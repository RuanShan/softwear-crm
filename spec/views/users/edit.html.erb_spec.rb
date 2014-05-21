require 'spec_helper'

describe 'users/edit.html.erb', user_spec: true do
	let!(:user) { create(:user) }
	before(:each) do
		assign(:user, user)
	end

	it 'has fields for firstname, lastname and email' do
		render
		within_form_for User do
			expect(rendered).to have_field_for :firstname
			expect(rendered).to have_field_for :lastname
			expect(rendered).to have_field_for :email
		end
	end

	it 'has submit button' do
		render
		expect(rendered).to have_selector 'input[type="submit"]'
	end

	it 'shows change password button if the user is viewing their own edit page' do
		assign(:current_user, user)
		render
		expect(rendered).to have_button_or_link_to edit_user_registration_path
	end

	it "does not show change password button if user is viewing someone else's page" do
		assign(:current_user, create(:alternate_user))
		render
		expect(rendered).to_not have_button_or_link_to edit_user_registration_path
	end

end