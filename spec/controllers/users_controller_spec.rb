require 'spec_helper'

describe UsersController, user_spec: true do
	let!(:valid_user) { create :user }
	before(:each) { sign_in valid_user }
	
	context '#new' do
		it 'redirects to Users::RegistrationsController#new' do
			get :new
			expect(response).to redirect_to new_user_registration_path
		end
	end
	context '#show' do
		it 'should not work' do
			expect{get :show}.to raise_error ActionController::UrlGenerationError
		end
	end
end