require 'spec_helper'

describe '/users/sessions/new.html.erb', user_spec: true do
	it 'displays fields for email and password' do
		render template: '/users/sessions/new.html.erb', locals: {
			resource: User.new, resource_name: 'user'
		}
		within_form_for User do
			expect(rendered).to have_field_for :email
			expect(rendered).to have_field_for :password
		end
	end

	it 'fills in the email field with a username if a user was locked' do
		assign :lock, { email: 'test@example.com', location: orders_path }
		render template: '/users/sessions/new.html.erb', locals: {
			resource: User.new, resource_name: 'user'
		}
		expect(rendered).to have_css '#user_email[value="test@example.com"]'
	end
end