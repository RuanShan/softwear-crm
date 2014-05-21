require 'spec_helper'

describe 'users/registrations/edit.html.erb', user_spec: true do
	let!(:user) { create(:user) }
	before(:each) do
		render template: 'users/registrations/edit.html.erb', locals: { resource:  user, resource_name: 'user' }
	end

	it 'fields necessary to change passwords' do
		within_form_for User do
			expect(rendered).to have_field_for :password
			expect(rendered).to have_field_for :password_confirmation
			expect(rendered).to have_field_for :current_password
		end
	end

	it 'does not have the email field' do
		within_form_for User do
			expect(rendered).to_not have_field_for :email
		end
	end
end