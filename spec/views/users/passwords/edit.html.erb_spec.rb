require 'spec_helper'

describe '/users/passwords/edit.html.erb', user_spec: true do
	before(:each) do
		render template: '/users/passwords/edit.html.erb', locals: {
		  resource: create(:user), resource_name: 'user' 
		}
	end

	it 'renders password fields' do
		within_form_for User do
			expect(rendered).to have_field_for :password
			expect(rendered).to have_field_for :password_confirmation
		end
	end

	it 'does not render current password field' do
		within_form_for User do
			expect(rendered).to_not have_field_for :current_password
		end
	end
end